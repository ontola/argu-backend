# frozen_string_literal: true

require 'test_helper'
require 'support/oauth_test_helpers'

class TokensClientCredentialsTest < ActionDispatch::IntegrationTest
  include OauthTestHelpers

  define_page
  let(:application) { create(:application) }
  let(:service_application) { create(:application, scopes: ['service']) }

  test 'Should not create client credentials without credentials' do
    assert_difference('Doorkeeper::AccessToken.count' => 0) do
      post_token_client_credentials(
        results: {error_type: 'invalid_client'}
      )
    end
  end

  test 'Should not create client credentials without secret' do
    assert_difference('Doorkeeper::AccessToken.count' => 0) do
      post_token_client_credentials(
        client_id: application.uid,
        results: {error_type: 'invalid_client'}
      )
    end
  end

  test 'Should not create client credentials for user client with service scope' do
    assert_difference('Doorkeeper::AccessToken.count' => 0) do
      post_token_client_credentials(
        client_id: application.uid,
        client_secret: application.secret,
        results: {error_type: 'invalid_scope'},
        scope: 'service'
      )
    end
  end

  test 'Should not create client credentials for user client with user scope' do
    assert_difference('Doorkeeper::AccessToken.count' => 1) do
      post_token_client_credentials(
        client_id: application.uid,
        client_secret: application.secret,
        results: {scope: 'user', refresh_token: false},
        scope: 'user'
      )
    end
  end

  test 'Should create client credentials for service client with service scope' do
    assert_difference('Doorkeeper::AccessToken.count' => 1) do
      post_token_client_credentials(
        client_id: service_application.uid,
        client_secret: service_application.secret,
        results: {scope: 'service', refresh_token: false},
        scope: 'service'
      )
    end
  end

  test 'Should create client credentials with guest scope' do
    assert_difference('Doorkeeper::AccessToken.count' => 1) do
      post_token_client_credentials(
        client_id: application.uid,
        client_secret: application.secret,
        results: {scope: 'guest', refresh_token: false}
      )
    end
  end

  private

  def post_token_client_credentials(scope: nil, redirect: nil, results: {}, client_id: nil, client_secret: nil)
    post oauth_token_path,
         headers: argu_headers(accept: :json),
         params: {
           grant_type: 'client_credentials',
           client_id: client_id,
           client_secret: client_secret,
           scope: scope,
           r: redirect
         }

    token_response(**results)
  end
end
