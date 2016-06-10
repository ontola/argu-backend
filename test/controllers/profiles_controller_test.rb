# frozen_string_literal: true
require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include Devise::TestHelpers, ProfilesHelper

  let(:user) { create(:user) }
  let(:user2) { create(:user) }

  ####################################
  # As User
  ####################################
  test 'user should get edit profile with own profile' do
    sign_in user

    get :edit, id: user.url

    assert_redirected_to settings_path(tab: :profile)
    assert_equal user, assigns(:resource), ''
  end

  test 'user should not get edit profile with other profile' do
    sign_in user

    get :edit, id: user2.url

    assert_response 302
    assert_equal user2, assigns(:resource)
  end
end
