require "test_helper"

class ForumsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get show" do
    sign_in users(:user)

    get :show, id: forums(:utrecht)
    assert_response :success
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:motions)
    assert_not_nil assigns(:questions)

    assert_not assigns(:motions).any?(&:is_trashed?), "Trashed motions are visible"
    assert_not assigns(:questions).any?(&:is_trashed?), "Trashed questions are visible"
  end

  test "should not show settings" do
    sign_in users(:user)

    get :settings, id: forums(:utrecht)
    assert_redirected_to root_path
  end

  test "should not show statistics" do
    sign_in users(:user)

    get :settings, id: forums(:utrecht)
    assert_redirected_to root_path
  end

  test "should not put update on others question" do
    sign_in users(:user)

    put :update, id: forums(:utrecht), question: {title: 'New title', content: 'new contents'}
    assert_redirected_to root_path
  end

end
