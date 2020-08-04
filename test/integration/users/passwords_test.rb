# frozen_string_literal: true

require 'test_helper'

module Users
  class PasswordsTest < ActionDispatch::IntegrationTest
    define_freetown
    let(:user) { create(:unconfirmed_user) }
    let(:user_no_shortname) { create(:user, :no_shortname, first_name: nil, last_name: nil) }
    let(:password_form) { RDF::URI('https:example.com/password') }

    ####################################
    # As guest
    ####################################
    test 'guest should get new password' do
      sign_in :guest_user
      get new_user_password_path
      assert_response 200
    end

    test 'guest should not post create password for non-existing email' do
      sign_in :guest_user
      post user_password_path,
           headers: argu_headers(referrer: password_form),
           params: {user: {email: 'wrong@email.com'}}
      assert_response :unprocessable_entity
      expect_errors(
        password_form,
        NS::SCHEMA[:email] => 'Not found'
      )
    end

    test 'guest should post create password for existing email' do
      sign_in :guest_user
      post user_password_path, params: {user: {email: user.email}}
      expect_ontola_action(snackbar: 'You will receive an email shortly with instructions to reset your password.')
      assert_response :created
    end

    test 'guest should not get edit password without token' do
      sign_in :guest_user
      get edit_user_password_path
      assert_not_a_user
    end

    test 'guest should get edit password with token' do
      sign_in :guest_user
      get edit_user_password_path(reset_password_token: '123')
      assert_response 200
    end

    test 'guest should not put update password with wrong token' do
      sign_in :guest_user
      put user_password_path,
          params: {
            user: {
              reset_password_token: 'wrong_token',
              password: 'new_password',
              password_confirmation: 'new_password'
            }
          }
      assert_response :unprocessable_entity
      assert_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'guest should not put update password with non-matching passwords' do
      sign_in :guest_user
      put user_password_path,
          headers: argu_headers(referrer: password_form),
          params: {
            user: {
              reset_password_token: user.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'other_password'
            }
          }
      assert_response :unprocessable_entity
      expect_errors(
        password_form,
        NS::ONTOLA[:passwordConfirmation] => "Doesn't match Password"
      )
      assert_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'guest should put update password with shortname' do
      sign_in :guest_user
      assert_not user.confirmed?
      put user_password_path,
          params: {
            user: {
              reset_password_token: user.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'new_password'
            }
          }
      assert_response :success
      assert_not_equal user.encrypted_password, user.reload.encrypted_password
      assert user.confirmed?

      expect_ontola_action(snackbar: 'Your password has been updated successfully')
    end

    test 'guest should put update password without shortname' do
      sign_in :guest_user
      put user_password_path,
          params: {
            user: {
              reset_password_token: user_no_shortname.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'new_password'
            }
          }
      assert_response :success
      assert_not_equal user_no_shortname.encrypted_password, user_no_shortname.reload.encrypted_password
    end

    ####################################
    # As user
    ####################################
    test 'user should get new password' do
      sign_in user
      get new_user_password_path
      assert_response :success
    end

    test 'user should not post create password for non-existing email' do
      sign_in user
      post user_password_path, params: {user: {email: 'wrong@email.com'}}
      assert_response :created
      assert_equal(response.headers['Location'], settings_iri)
    end

    test 'user should post create password for existing email' do
      create_email_mock('reset_password_instructions', user.email, token_url: /.+/)

      sign_in user
      post user_password_path, params: {user: {email: user.email}}
      assert_response :created
      assert_equal(response.headers['Location'], settings_iri)
      expect_ontola_action(snackbar: 'You will receive an email shortly with instructions to reset your password.')

      assert_email_sent
    end

    test 'user should not get edit password without token' do
      sign_in user
      get edit_user_password_path
      assert_not_a_user
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
      assert_response :unprocessable_entity
      assert_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'user should not put update password with non-matching passwords' do
      sign_in user
      put user_password_path,
          headers: argu_headers(referrer: password_form),
          params: {
            user: {
              reset_password_token: user.send(:set_reset_password_token),
              password: 'new_password',
              password_confirmation: 'other_password'
            }
          }
      assert_response :unprocessable_entity
      expect_errors(
        password_form,
        NS::ONTOLA[:passwordConfirmation] => "Doesn't match Password"
      )
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
      assert_response :success
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
      assert_response :success
      assert_not_equal user_no_shortname.encrypted_password, user_no_shortname.reload.encrypted_password
    end

    private

    def edit_user_password_path(*args)
      "#{argu.iri}#{super}"
    end

    def new_user_password_path
      "#{argu.iri}#{super}"
    end

    def user_password_path
      "#{argu.iri}#{super}"
    end

    def settings_iri
      ActsAsTenant.with_tenant(argu) do
        user.menu(:profile).iri(fragment: :settings)
      end
    end
  end
end
