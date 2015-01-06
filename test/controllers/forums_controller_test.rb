require "test_helper"

class ForumsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get show" do
    sign_in users(:user)

    get :show, id: forums(:utrecht)
    assert_response :success
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:items)

    assert_not assigns(:items).any?(&:is_trashed?), "Trashed motions are visible"
  end

  test "should not show settings" do
    sign_in users(:user)

    get :settings, id: forums(:utrecht)
    assert_redirected_to root_path, "Settings are publicly visible"
  end

  test "should not show statistics" do
    sign_in users(:user)

    get :statistics, id: forums(:utrecht)
    assert_redirected_to root_path, "Statistics are publicly visible"
  end

  test "should not leak closed children to non-members" do
    sign_in users(:user)

    get :show, id: forums(:amsterdam)
    assert_response :success

    assert_nil assigns(:items), "Closed forums are leaking content"
  end

  test "should not show hidden to non-members" do
    sign_in users(:user)

    get :show, id: forums(:hidden)
    assert_redirected_to root_path, "Hidden forums are visible"
  end

  test "should not put update on others question" do
    sign_in users(:user)

    put :update, id: forums(:utrecht), question: {title: 'New title', content: 'new contents'}
    assert_redirected_to root_path, "Others can update questions"
  end


  ####################################
  # For managers
  ####################################

  test "should show settings" do
    sign_in users(:user_utrecht_manager)

    get :settings, id: forums(:utrecht)
    assert_response :success
    assert assigns(:forum)
  end

  test "should show statistics" do
    sign_in users(:user_utrecht_manager)

    get :statistics, id: forums(:utrecht)
    assert_response :success
    assert assigns(:forum)
    assert assigns(:tags), "Doesn't assign tags"
    assert_equal 1, assigns(:tags).length
  end

end
