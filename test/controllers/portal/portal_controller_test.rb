# frozen_string_literal: true
require 'test_helper'

class Portal::PortalControllerTest < ActionController::TestCase
  define_freetown
  let(:user) { create(:user) }
  let(:staff) { create(:user, :staff) }

  ####################################
  # As User
  ####################################
  test 'user should not get show' do
    sign_in user

    get :home
    assert_response 403
  end

  ####################################
  # As Staff
  ####################################
  test 'staff should get show' do
    sign_in staff

    get :home
    assert_response :success
    assert assigns(:forums)
    assert assigns(:pages)
  end
end
