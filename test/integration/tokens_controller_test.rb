# frozen_string_literal: true
require 'test_helper'

class TokensControllerTest < ActionDispatch::IntegrationTest
  ####################################
  # As Guest
  ####################################
  test 'Guest should not post create token without credentials' do
    post oauth_token_path

    assert_response 401
  end

  ####################################
  # As User
  ####################################
  let!(:user) { create(:user) }

  test 'User should post create token with credentials' do
    post oauth_token_path,
         headers: {
           HTTP_HOST: 'other.example'
         },
         params: {
           email: user.email,
           password: user.password,
           grant_type: 'password',
           scope: 'user'
         }

    res = JSON.parse(response.body)
    assert_response 200
    assert_equal 'user', res['scope']
    assert_equal 'bearer', res['token_type']
    assert_equal 1_209_600, res['expires_in']
    token = JWT.decode(res['access_token'], nil, false)[0]
    token_user = token['user']
    assert_equal 'user', token_user['type']
    assert_equal user.email, token_user['email']
    assert_equal user.id, token_user['id']
  end

  test 'User should post create token with username' do
    post oauth_token_path,
         headers: {
           HTTP_HOST: 'other.example'
         },
         params: {
           username: user.email,
           password: user.password,
           grant_type: 'password',
           scope: 'user'
         }

    assert_response 200
  end

  test 'User should not post create token with bad credentials' do
    post oauth_token_path,
         headers: {
           HTTP_HOST: 'other.example'
         },
         params: {
           email: user.email,
           password: 'wrong',
           grant_type: 'password',
           scope: 'user'
         }

    assert_response 302
  end

  test 'User should not post create token with service scope' do
    post oauth_token_path,
         headers: {
           HTTP_HOST: 'other.example'
         },
         params: {
           email: user.email,
           password: user.password,
           grant_type: 'password',
           scope: 'service'
         }

    assert_response 401
  end

  test 'User should not post create token with user and service scope' do
    post oauth_token_path,
         headers: {
           HTTP_HOST: 'other.example'
         },
         params: {
           email: user.email,
           password: user.password,
           grant_type: 'password',
           scope: 'user service'
         }

    assert_response 401
  end
end
