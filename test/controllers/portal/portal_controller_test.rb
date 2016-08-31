require 'test_helper'

class Portal::PortalControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  let!(:freetown) { create(:forum, name: 'freetown') }
  let(:user) { create(:user) }
  let(:staff) { create(:user, :staff) }

  ####################################
  # As User
  ####################################
  test 'user should not get show' do
    sign_in user

    get :home
    assert_redirected_to root_path
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
