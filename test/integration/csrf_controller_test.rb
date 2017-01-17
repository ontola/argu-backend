# frozen_string_literal: true
require 'test_helper'

class TokensControllerTest < ActionDispatch::IntegrationTest
  test 'should not get show CSRF token without access token' do
    get csrf_path

    assert_response 403
  end

  ####################################
  # As Guest
  ####################################
  let(:guest_token) { create(:guest_token, resource_owner_id: SecureRandom.base64(30)) }

  test 'Guest should not get show CSRF token' do
    get csrf_path,
        headers: {
          Authorization: "Bearer #{guest_token.token}"
        }

    assert_response 403
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }
  let(:user_token) { create(:user_token, resource_owner_id: user.id) }

  test 'User should not get show CSRF token' do
    get csrf_path,
        headers: {
          Authorization: "Bearer #{user_token.token}"
        }

    assert_response 403
  end

  ####################################
  # As Service
  ####################################
  let(:service_token) { create(:service_token) }

  test 'should get show CSRF token' do
    get csrf_path,
        headers: {
          Authorization: "Bearer #{service_token.token}"
        }

    assert_response 200
    res = JSON.parse(response.body)
    assert res['token'].length > 15
  end
end
