require "test_helper"

class Portal::PortalControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  #####Staff#####
  test "staff should get show" do
    sign_in users(:user_thom)

    get :home
    assert_response :success
    assert assigns(:forums)
    assert assigns(:pages)
  end

  #####Users#####
  test "user should not get show" do
    sign_in users(:user)

    get :home
    assert_redirected_to root_path
  end
end
