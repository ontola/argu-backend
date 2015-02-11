require "test_helper"

class StaticPagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get team" do
    sign_in users(:user)

    get :team

    assert_response :success
    assert assigns(:document)
    assert_equal 'block--full', assigns(:document)['sections'].first['type']
  end

  test "should not get product" do
    sign_in users(:user)

    get :product

    assert_redirected_to root_path
  end

  test "staff should get product" do
    sign_in users(:user_thom)

    get :product

    assert_response :success
  end

end