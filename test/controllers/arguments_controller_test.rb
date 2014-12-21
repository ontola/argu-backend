require "test_helper"

class ArgumentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get show" do
    sign_in users(:user)

    get :show, id: arguments(:one)

    assert_response :success
    assert assigns(:argument)
    assert assigns(:comments)

    assert_not assigns(:comments).any? { |c| c.is_trashed? && c.body != '[DELETED]' }, "Trashed comments are visible"
  end
end
