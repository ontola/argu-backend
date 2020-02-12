# frozen_string_literal: true

require 'test_helper'

class TokensTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:guest_user) { create_guest_user }
  let(:other_guest_user) { create_guest_user(id: 'other_id') }
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

  ####################################
  # GENERATE GUEST TOKEN
  # ##################################
  test 'Guest should get guest token if none is present and reuse it' do
    sign_in :guest_user

    assert_difference("Doorkeeper::AccessToken.where(scopes: 'guest').count", 0) do
      get motion.iri.path, headers: argu_headers(accept: :json)
    end
    assert_equal(decoded_token_from_response['scopes'], %w[guest])

    get motion.iri.path, headers: argu_headers(accept: :json, bearer: client_token_from_response)
    assert_nil response.headers['New-Authorization']
  end

  ####################################
  # WITHOUT CREDENTIALS
  ####################################
  test 'Guest should not post create token without params' do
    sign_in :guest_user

    post oauth_token_path, headers: argu_headers(accept: :json)

    expect_error_type('invalid_request')
    expect_error_code('SERVER_ERROR')
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
      'Favorite.count' => 0,
      'Argu::Redis.keys("temp*").count' => -2
    }
    assert_difference(differences) do
      Sidekiq::Testing.inline! do
        token_user = post_token(redirect: freetown.iri.path)
        assert_equal user.email, token_user['email']
        assert_equal user.id, token_user['id']
      end
    end
  end

  test 'User should post create token with username' do
    sign_in guest_user
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post_token(name: user.url)
    end
  end

  test 'User should post create token with caps' do
    sign_in guest_user
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post_token(name: user.email.capitalize)
    end
  end

  test 'User should post create token with r' do
    sign_in guest_user
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post_token(redirect: freetown.iri.path)
    end
  end

  ####################################
  # EMPTY PASSWORD
  ####################################
  test 'User should not post create token with credentials and empty password' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(password: nil, err_code: 'WRONG_PASSWORD')
    end
  end

  test 'User should not post create token with credentials and blank password' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(password: '', err_code: 'WRONG_PASSWORD')
    end
  end

  ####################################
  # WRONG PASSWORD
  ####################################
  test 'User should not post create token with wrong password' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(password: 'wrong', err_code: 'WRONG_PASSWORD')
    end
  end

  test 'User should not post create token with wrong password and r' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(password: 'wrong', err_code: 'WRONG_PASSWORD', redirect: freetown.iri.path)
    end
  end

  ####################################
  # UNKOWN EMAIL
  ####################################
  test 'User should not post create token with unknown email for other domain' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(name: 'wrong@example.com', err_code: 'UNKNOWN_EMAIL')
    end
  end

  test 'User should not post create token with unknown email and r for Argu domain' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(name: 'wrong@example.com', err_code: 'UNKNOWN_EMAIL', redirect: freetown.iri.path)
    end
  end

  ####################################
  # UNKOWN USERNAME
  ####################################
  test 'User should not post create token with unknown username' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(name: 'wrong', err_code: 'UNKNOWN_USERNAME')
    end
  end

  test 'User should not post create token with r and unknown username' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(name: 'wrong', err_code: 'UNKNOWN_USERNAME', redirect: freetown.iri.path)
    end
  end

  ####################################
  # WITH SERVICE_SCOPE
  ####################################
  test 'User should not post create token with service scope' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(err_type: 'invalid_scope', scope: 'service')
    end
  end

  test 'User should not post create token with user and service scope for other domain' do
    sign_in guest_user
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(err_type: 'invalid_scope', scope: 'user service')
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
                      'Argu::Redis.keys("temporary*").count' => -1,
                      'Favorite.count' => 1) do
      Sidekiq::Testing.inline! do
        token_user = post_token(
          name: unconfirmed_user.email,
          password: unconfirmed_user.password,
          redirect: freetown.iri.path
        )
        assert_equal unconfirmed_user.email, token_user['email']
        assert_equal unconfirmed_user.id, token_user['id']
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
      post_token(err_code: 'ACCOUNT_LOCKED', password: 'wrong')
    end

    assert_not_nil user.reload.locked_at
    assert_email_sent
  end

  test 'Locked user should not post token' do
    sign_in guest_user

    user.update!(locked_at: Time.current)

    assert_no_difference('Doorkeeper::AccessToken.count') do
      post_token(err_code: 'ACCOUNT_LOCKED')
    end
  end

  private

  def expect_error_code(error_code)
    assert_equal(parsed_body['code'], error_code, parsed_body)
  end

  def expect_error_type(error_type)
    assert_equal(parsed_body['error'], error_type, parsed_body)
  end

  def oauth_token_path
    "/#{argu.url}#{super}"
  end

  # rubocop:disable Metrics/AbcSize, Metrics/ParameterLists
  def post_token(err_code: nil, err_type: nil, name: user.email, password: user.password, scope: 'user', redirect: nil)
    post oauth_token_path,
         headers: argu_headers(accept: :json),
         params: {
           username: name,
           password: password,
           grant_type: 'password',
           scope: scope,
           r: redirect
         }

    if err_code || err_type
      expect_error_type(err_type || 'invalid_grant')
      expect_error_code(err_code) if err_code
      assert_response 401
    else
      assert_response 200

      assert_equal 'user', parsed_body['scope']
      assert_equal 'Bearer', parsed_body['token_type']
      assert_equal 1_209_600, parsed_body['expires_in']
      token = JWT.decode(parsed_body['access_token'], nil, false)[0]
      token_user = token['user']
      assert_equal 'user', token_user['type']
      token_user
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/ParameterLists
end
