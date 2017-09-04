# frozen_string_literal: true

require 'test_helper'

class AccessTokenRedirectTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:access_token) { AccessToken.create(profile: create(:profile)) }

  ####################################
  # As Guest
  ####################################
  test 'guest should redirect to service' do
    assert_difference('access_token.reload.usages') do
      get forum_path(freetown, at: access_token.access_token)
      assert_redirected_to argu_url("/tokens/#{access_token.access_token}")
    end
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should redirect to service' do
    sign_in user
    assert_difference('access_token.reload.usages') do
      get forum_path(freetown, at: access_token.access_token)
      assert_redirected_to argu_url("/tokens/#{access_token.access_token}")
    end
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should redirect to service' do
    sign_in staff
    assert_difference('access_token.reload.usages') do
      get forum_path(freetown, at: access_token.access_token)
      assert_redirected_to argu_url("/tokens/#{access_token.access_token}")
    end
  end
end
