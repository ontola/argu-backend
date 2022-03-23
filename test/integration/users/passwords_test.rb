# frozen_string_literal: true

require 'test_helper'

module Users
  class PasswordsTest < ActionDispatch::IntegrationTest
    define_freetown
    let(:user) { create(:unconfirmed_user) }
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
        NS.schema.email => 'Not found'
      )
    end

    test 'guest should post create password for existing email' do
      create_email_mock('reset_password_instructions', user.email, token_url: /.+/)

      sign_in :guest_user
      post user_password_path, params: {user: {email: user.email}}
      expect_ontola_action(snackbar: 'You will receive an email shortly with instructions to reset your password.')
      assert_response :created

      assert_email_sent
    end

    test 'guest should not get edit password without token' do
      sign_in :guest_user
      get edit_user_password_path
      assert_response 200
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

    test 'guest should not put update password without token' do
      sign_in :guest_user
      put user_password_path,
          params: {
            user: {
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
        NS.ontola[:passwordConfirmation] => "Doesn't match Password"
      )
      assert_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'guest should put update password' do
      create_email_mock('password_changed', user.email)

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
      assert_email_sent

      expect_ontola_action(snackbar: 'Your password has been updated successfully')
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
      create_email_mock('reset_password_instructions', user.email, token_url: /.+/)

      sign_in user
      post user_password_path, params: {user: {email: 'wrong@email.com'}}
      assert_response :created
      assert_equal(response.headers['Location'], '/argu/u/session/new')

      assert_email_sent
    end

    test 'user should post create password for existing email' do
      create_email_mock('reset_password_instructions', user.email, token_url: /.+/)

      sign_in user
      post user_password_path, params: {user: {email: user.email}}
      assert_response :created
      assert_equal(response.headers['Location'], '/argu/u/session/new')
      expect_ontola_action(snackbar: 'You will receive an email shortly with instructions to reset your password.')

      assert_email_sent
    end

    test 'user should not get edit password without token' do
      sign_in user
      get edit_user_password_path
      assert_response 200
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
        NS.ontola[:passwordConfirmation] => "Doesn't match Password"
      )
      assert_equal user.encrypted_password, user.reload.encrypted_password
    end

    test 'user should put update password' do
      create_email_mock('password_changed', user.email)

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

      assert_email_sent
    end

    private

    def edit_user_password_path(params = nil)
      ["#{argu.iri}/u/password/edit", params&.to_param].compact.join('?')
    end

    def new_user_password_path
      "#{argu.iri}/u/password/new"
    end

    def user_password_path
      "#{argu.iri}/u/password"
    end
  end
end
