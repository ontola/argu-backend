# frozen_string_literal: true

require 'test_helper'
require 'support/oauth_test_helpers'

class TokensTest < ActionDispatch::IntegrationTest
  include OauthTestHelpers

  define_freetown
  define_cairo
  let(:guest_user) { create_guest_user }
  let(:user) { create(:user) }

  test 'Guest should not post create token without params' do
    sign_in :guest_user

    post oauth_token_path, headers: argu_headers(accept: :json)

    expect_error_type('invalid_request')
    expect_error_code('MISSING_REQUIRED_PARAMETER')
    assert_response 400
  end

  ####################################
  # Refreshing
  ####################################
  test 'User should post create token and refresh' do
    sign_in guest_user
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post_token_password
    end
    refresh_token = parsed_body['refresh_token']
    session_id = parsed_access_token['session_id']
    assert_equal session_id.class, String
    assert refresh_token
    sleep 1
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      refresh_access_token(refresh_token)
    end
    token_response
    assert_equal session_id, parsed_access_token['session_id']
    sleep 1
    assert_difference('Doorkeeper::AccessToken.count', 0) do
      refresh_access_token(refresh_token)
    end
    token_response(error_type: 'invalid_grant')
  end

  test 'User should refresh token with expired token' do
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
  # Revoking
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

  ####################################
  # Make request with expired token
  ####################################
  test 'Make request to public resource with expired token' do
    sign_in freetown.publisher
    get freetown.iri
    assert_response :success

    sign_in expired_token(freetown.publisher).token
    get freetown.iri
    assert_response :success
  end

  test 'Make request to private resource with expired token' do
    sign_in cairo.publisher
    get cairo.iri
    assert_response :success

    sign_in expired_token(cairo.publisher).token
    get cairo.iri
    assert_response :forbidden
  end
end
