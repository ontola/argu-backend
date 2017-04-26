# frozen_string_literal: true
require 'test_helper'

module Users
  class ConfirmationsTest < ActionDispatch::IntegrationTest
    ####################################
    # As guest
    ####################################
    test 'guest should get show confirmation' do
      assert_not user.confirmed?
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
    end

    ####################################
    # As user
    ####################################
    let(:user) { create(:user, :unconfirmed) }

    test 'user without shortname should get show confirmation' do
      sign_in user
      user.shortname.destroy
      user.reload
      assert_not user.confirmed?
      assert_not user.url.present?
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
    end

    test 'user without finished intro should get show confirmation' do
      sign_in user
      user.update(finished_intro: false)
      user.reload
      assert_not user.confirmed?
      assert_not user.finished_intro?
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
    end

    test 'user should get show confirmation' do
      sign_in user
      assert_not user.confirmed?
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
    end
  end
end
