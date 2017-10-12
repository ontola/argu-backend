# frozen_string_literal: true

require 'test_helper'

module Users
  class PasswordsTest < ActionDispatch::IntegrationTest
    define_freetown
    let(:user) { create(:user, :unconfirmed) }
    let(:user_no_shortname) { create(:user, :no_shortname, first_name: nil, last_name: nil) }

    ####################################
    # As guest
    ####################################
    test 'guest should get new password' do
      get new_user_password_path
      assert_response 200
    end

    test 'guest should not post create password for non-existing email' do
      post user_password_path, params: {user: {email: 'wrong@email.com'}}
      assert_response 200
      assert_select 'p.inline-errors', 'not found'
    end

    test 'guest should post create password for existing email' do
      post user_password_path, params: {user: {email: user.email}}
      assert_equal flash[:notice], 'You will receive an email shortly with instructions to reset your password.'
      assert_redirected_to new_user_session_path
    end

    test 'guest should not get edit password without token' do
      get edit_user_password_path
      assert_equal flash[:alert],
                   'You cannot access this page without being redirected by a password reset mail. '\
                   'Please check the entered address.'
      assert_redirected_to new_user_session_path
    end

    test 'guest should get edit password with token' do
      get edit_user_password_path(reset_password_token: '123')
      assert_response 200
    end

    test 'guest should not put update password with wrong token' do
      put user_password_path,
          params: {
            user: {
              reset_password_token: 'wrong_token',
              password: 'new_password',
              password_confirmation: 'new_password'
            }
          }
      assert_response 200
      assert_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'guest should not put update password with non-matching passwords' do
      put user_password_path,
          params: {
            user: {
              reset_password_token: user.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'other_password'
            }
          }
      assert_response 200
      assert_select 'p.inline-errors', 'doesn\'t match Password'
      assert_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'guest should put update password with shortname' do
      put user_password_path,
          params: {
            user: {
              reset_password_token: user.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'new_password'
            }
          }
      assert_redirected_to root_path
      assert_not_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'guest should put update password without shortname' do
      put user_password_path,
          params: {
            user: {
              reset_password_token: user_no_shortname.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'new_password'
            }
          }
      assert_redirected_to setup_users_url
      assert_not_equal user_no_shortname.encrypted_password, user_no_shortname.reload.encrypted_password
    end

    ####################################
    # As user
    ####################################
    test 'user should get new password' do
      sign_in user
      get new_user_password_path
      assert_response 200
    end

    test 'user should not post create password for non-existing email' do
      sign_in user
      post user_password_path, params: {user: {email: 'wrong@email.com'}}
      assert_redirected_to settings_user_path
    end

    test 'user should post create password for existing email' do
      sign_in user
      post user_password_path, params: {user: {email: user.email}}
      assert_equal flash[:notice], 'You will receive an email shortly with instructions to reset your password.'
      assert_redirected_to settings_user_path
    end

    test 'user should not get edit password without token' do
      sign_in user
      get edit_user_password_path
      assert_equal flash[:alert],
                   'You cannot access this page without being redirected by a password reset mail. '\
                   'Please check the entered address.'
      assert_redirected_to new_user_session_path
    end

    test 'user should get edit password with token' do
      sign_in user
      get edit_user_password_path(reset_password_token: '123')
      assert_response 200
    end

    test 'user should not put update password with wrong token' do
      sign_in user
      put user_password_path,
          params: {
            user: {
              reset_password_token: 'wrong_token',
              password: 'new_password',
              password_confirmation: 'new_password'
            }
          }
      assert_response 200
      assert_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'user should not put update password with non-matching passwords' do
      sign_in user
      put user_password_path,
          params: {
            user: {
              reset_password_token: user.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'other_password'
            }
          }
      assert_response 200
      assert_select 'p.inline-errors', 'doesn\'t match Password'
      assert_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'user should put update password with shortname' do
      sign_in user
      put user_password_path,
          params: {
            user: {
              reset_password_token: user.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'new_password'
            }
          }
      assert_redirected_to root_path
      assert_not_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'user should put update password without shortname' do
      sign_in user_no_shortname
      put user_password_path,
          params: {
            user: {
              reset_password_token: user_no_shortname.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'new_password'
            }
          }
      assert_redirected_to setup_users_url
      assert_not_equal user_no_shortname.encrypted_password, user_no_shortname.reload.encrypted_password
    end
  end
end
