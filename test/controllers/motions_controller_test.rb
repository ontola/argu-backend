require "test_helper"

class MotionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get show" do
    sign_in users(:user)

    get :show, id: motions(:one)

    assert_response :success
    assert_not_nil assigns(:motion)
    assert_not_nil assigns(:votes)
    assert_not_nil assigns(:opinions)

    assert_not assigns(:votes).any? { |arr| arr[1][:collection].any?(&:is_trashed?) }, "Trashed arguments are visible"
  end

  test "should get new" do
    sign_in users(:user)

    get :new, forum_id: forums(:utrecht)

    assert_response :success
    assert_not_nil assigns(:motion)
  end

  test "should post create" do
    sign_in users(:user)

    assert_difference('Motion.count') do
      post :create, forum_id: :utrecht, motion: {title: 'Motion', content: 'Contents'}
    end
    assert_not_nil assigns(:motion)
    assert_not_nil assigns(:forum)
    assert_redirected_to motion_path(assigns(:motion))
  end

  test "should put update on own motion" do
    sign_in users(:user)

    put :update, id: motions(:one), motion: {title: 'New title', content: 'new contents'}

    assert_not_nil assigns(:motion)
    assert_equal 'New title', assigns(:motion).title
    assert_equal 'new contents', assigns(:motion).content
    assert_redirected_to motion_url(assigns(:motion))
  end

  test "should not put update on others motion" do
    sign_in users(:user2)

    put :update, id: motions(:one), motion: {title: 'New title', content: 'new contents'}

    assert_equal motions(:one), assigns(:motion)
  end

end
