# frozen_string_literal: true

require 'test_helper'
require 'support/oauth_test_helpers'

class TokensTest < ActionDispatch::IntegrationTest
  include OauthTestHelpers

  define_freetown
  let(:guest_user) { create_guest_user }
  let(:other_guest_user) { create_guest_user(id: 'other_id') }
  let(:two_fa_user) { create(:two_fa_user) }
  let(:motion) { create(:motion, parent: freetown) }
  let(:motion2) { create(:motion, parent: freetown) }
  let(:vote) { create(:vote, parent: motion2.default_vote_event, publisher: user) }
  let(:guest_vote) do
    create(:vote, parent: motion.default_vote_event, creator: guest_user.profile, publisher: guest_user)
  end
  let(:guest_vote2) do
    create(:vote, parent: motion2.default_vote_event, creator: guest_user.profile, publisher: guest_user)
  end
  let(:other_guest_vote) do
    create(:vote,
           parent: motion.default_vote_event,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end
  let!(:user) { create(:user) }
  let!(:user_without_password) { create(:user, :no_password) }
  let(:application) { create(:application) }

  ####################################
  # WITHOUT CREDENTIALS
  ####################################
  test 'Guest should not post create token without params' do
    sign_in :guest_user

    post oauth_token_path, headers: argu_headers(accept: :json)

    expect_error_type('invalid_request')
    expect_error_code('SERVER_ERROR')
    assert_response 400
  end

  ####################################
  # WITH WRONG CLIENT
  ####################################
  test 'Guest should not post create token without client' do
    sign_in :guest_user

    post oauth_token_path,
         headers: argu_headers(accept: :json),
         params: {
           username: user.email,
           password: user.password,
           grant_type: 'password',
           scope: 'user'
         }

    expect_error_type('invalid_client')
    assert_response 401
  end

  test 'Guest should not post create token without client secret' do
    sign_in :guest_user

    post oauth_token_path,
         headers: argu_headers(accept: :json),
         params: {
           client_id: Doorkeeper::Application.argu.uid,
           username: user.email,
           password: user.password,
           grant_type: 'password',
           scope: 'user'
         }

    expect_error_type('invalid_client')
    assert_response 401
  end

  test 'Guest should not post create token with wrong client secret' do
    sign_in :guest_user

    post oauth_token_path,
         headers: argu_headers(accept: :json),
         params: {
           client_id: Doorkeeper::Application.argu.uid,
           username: user.email,
           password: user.password,
           grant_type: 'password',
           scope: 'user'
         }

    expect_error_type('invalid_client')
    assert_response 401
  end

  ####################################
  # SUCCESSFUL
  ####################################
  test 'User should post create token with credentials storing temp votes' do
    sign_in guest_user
    guest_vote
    guest_vote2
    other_guest_vote
    vote

    differences = {
      'Doorkeeper::AccessToken.count' => 1,
      'Vote.count' => 1,
      'Argu::Redis.keys("temp*").count' => -2
    }
    assert_difference(differences) do
      Sidekiq::Testing.inline! do
        token_user = post_token_password(redirect: freetown.iri.path)
        assert_equal user.email, token_user['email']
        assert_equal user.id.to_s, token_user['id']
      end
    end
  end

  test 'User should post create token with username' do
    sign_in guest_user
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post_token_password(name: user.url)
    end
  end

  test 'User should post create token with caps' do
    sign_in guest_user
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post_token_password(name: user.email.capitalize)
    end
  end

  test 'User should post create token with redirect_url' do
    sign_in guest_user
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post_token_password(redirect: freetown.iri.path)
    end
  end

  ####################################
  # REFRESH TOKENS
  ####################################
  test 'User should post create token and refresh' do
    sign_in guest_user
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post_token_password
    end
    refresh_token = parsed_body['refresh_token']
    assert refresh_token
    sleep 1
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      refresh_access_token(refresh_token)
    end
    token_response
    sleep 1
    assert_difference('Doorkeeper::AccessToken.count', 0) do
      refresh_access_token(refresh_token)
    end
    token_response(error_type: 'invalid_grant')
  end

  test 'User should not refresh token with expired token' do
    token = expired_token(user)
    sign_in token.token

    assert_difference('Doorkeeper::AccessToken.count', 1) do
      refresh_access_token(token.refresh_token)
    end
    token_response(ttl: 1)
    sleep 1
    assert_difference('Doorkeeper::AccessToken.count', 0) do
      refresh_access_token(token.refresh_token)
    end
    token_response(error_type: 'invalid_grant')
  end

  test 'User should not refresh token without refresh_token' do
    sign_in user

    assert_difference('Doorkeeper::AccessToken.count', 0) do
      refresh_access_token(nil)
    end
    token_response(error_type: 'invalid_request')
  end

  ####################################
  # WITH 2FA
  ####################################
  test 'User with 2fa should post create token' do
    sign_in guest_user
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      assert_nil(
        post_token_password(
          name: two_fa_user.email,
          results: {
            refresh_token: false,
            scope: nil,
            ttl: nil
          }
        )
      )
    end
    location_segments = response.headers['Location'].split('=')
    assert_equal(location_segments[0], 'http://argu.localtest/argu/u/otp_attempt/new?session')
    session = decode_token(location_segments[1])
    assert_equal(session.keys.sort, %w[exp redirect_uri user_id])
    assert_equal(session['user_id'].to_i, two_fa_user.id)
    assert(session['exp'].to_i <= 10.minutes.from_now.to_i)
  end

  ####################################
  # AS GUEST
  ####################################
  test 'Guest should post create token with guest scope without username' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      token = post_token_password(
        name: nil,
        password: nil,
        scope: 'guest',
        results: {scope: 'guest'}
      )
      assert token['id']
      assert_equal Doorkeeper::AccessToken.last.resource_owner_id, token['id']
    end
  end

  ####################################
  # CLIENT_CREDENTIALS
  ####################################
  test 'Service should not post create client credentials without credentials' do
    sign_in :service
    assert_difference('Doorkeeper::AccessToken.count' => 0) do
      post_token_client_credentials(results: {error_type: 'invalid_client'})
    end
  end

  test 'Service should not post create client credentials without secret' do
    sign_in :service
    assert_difference('Doorkeeper::AccessToken.count' => 0) do
      post_token_client_credentials(client_id: application.uid, results: {error_type: 'invalid_client'})
    end
  end

  test 'Service should not post create client credentials with user scope' do
    sign_in :service
    assert_difference('Doorkeeper::AccessToken.count' => 0) do
      post_token_client_credentials(
        client_id: application.uid,
        client_secret: application.secret,
        results: {error_type: 'invalid_grant'},
        scope: 'user'
      )
    end
  end

  test 'Service should post create client credentials' do
    sign_in :service
    assert_difference('Doorkeeper::AccessToken.count' => 1) do
      post_token_client_credentials(
        client_id: application.uid,
        client_secret: application.secret,
        results: {scope: 'guest', refresh_token: false}
      )
    end
  end

  ####################################
  # EMPTY PASSWORD
  ####################################
  test 'User should not post create token with credentials and empty password' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token_password(password: nil, results: {error_code: 'WRONG_PASSWORD'})
    end
  end

  test 'User should not post create token with credentials and blank password' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token_password(password: '', results: {error_code: 'WRONG_PASSWORD'})
    end
  end

  ####################################
  # WRONG PASSWORD
  ####################################
  test 'User should not post create token with wrong password' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token_password(password: 'wrong', results: {error_code: 'WRONG_PASSWORD'})
    end
  end

  test 'User should not post create token with wrong password and r' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token_password(password: 'wrong', results: {error_code: 'WRONG_PASSWORD'}, redirect: freetown.iri.path)
    end
  end

  ####################################
  # UNKOWN EMAIL
  ####################################
  test 'User should not post create token with unknown email' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token_password(name: 'wrong@example.com', results: {error_code: 'UNKNOWN_EMAIL'})
    end
  end

  ####################################
  # UNKOWN USERNAME
  ####################################
  test 'User should not post create token with unknown username' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token_password(name: 'wrong', results: {error_code: 'UNKNOWN_USERNAME'})
    end
  end

  ####################################
  # WITH SERVICE_SCOPE
  ####################################
  test 'User should not post create token with service scope' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token_password(results: {error_type: 'invalid_scope'}, scope: 'service')
    end
  end

  ####################################
  # As Unconfirmed User
  ####################################
  let(:unconfirmed_user) { create(:unconfirmed_user) }

  test 'Unconfirmed user should post create token transfering temp votes' do
    sign_in guest_user
    guest_vote
    other_guest_vote

    assert_difference('Doorkeeper::AccessToken.count' => 1,
                      'Vote.count' => 1,
                      'Argu::Redis.keys("temporary*").count' => -1) do
      Sidekiq::Testing.inline! do
        token_user = post_token_password(
          name: unconfirmed_user.email,
          password: unconfirmed_user.password,
          redirect: freetown.iri.path
        )
        assert_equal unconfirmed_user.email, token_user['email']
        assert_equal unconfirmed_user.id.to_s, token_user['id']
      end
    end
  end

  ####################################
  # Locking
  ####################################
  test 'User should lock after exceeding failed_attempts limit' do
    sign_in guest_user
    create_email_mock('unlock_instructions', user.email, token_url: /.+/)

    user.update!(failed_attempts: 19)
    assert_nil user.locked_at

    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token_password(results: {error_code: 'ACCOUNT_LOCKED'}, password: 'wrong')
    end

    assert_not_nil user.reload.locked_at
    assert_email_sent
  end

  test 'Locked user should not post token' do
    sign_in guest_user

    user.update!(locked_at: Time.current)

    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token_password(results: {error_code: 'ACCOUNT_LOCKED'})
    end
  end

  ####################################
  # Make request with expired token
  ####################################
  test 'Make request with expired token' do
    sign_in expired_token(user).token

    get argu.iri

    token_response(error_type: 'invalid_token')
  end

  ####################################
  # Revoke token
  ####################################
  test 'user should revoke token' do
    token = doorkeeper_token_for(user)
    sign_in token.token

    assert_difference('Doorkeeper::AccessToken.count' => 0, 'Doorkeeper::AccessToken.active_for(user).count' => -1) do
      post oauth_revoke_path,
           params: {
             client_id: Doorkeeper::Application.argu.uid,
             client_secret: Doorkeeper::Application.argu.secret,
             token: token.token
           }
    end
    assert_response :success
  end
end
