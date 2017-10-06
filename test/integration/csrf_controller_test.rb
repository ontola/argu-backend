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
  test 'Guest should not get show CSRF token' do
    sign_in :guest

    get csrf_path

    assert_response 403
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'User should not get show CSRF token' do
    sign_in user

    get csrf_path

    assert_response 403
  end

  ####################################
  # As Service
  ####################################
  test 'should get show CSRF token' do
    sign_in :service

    get csrf_path

    assert_response 200
    assert parsed_body['token'].length > 15
  end
end
