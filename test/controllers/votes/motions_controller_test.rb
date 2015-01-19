require "test_helper"

class Votes::MotionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should post create" do
    sign_in users(:user)

    assert_difference('Vote.count') do
      post :create, motion_id: motions(:one), for: :pro, format: :js
    end

    assert_response :success
    assert assigns(:motion)
    assert assigns(:vote)
  end

  test "should return 304 if vote already exists" do
    sign_in users(:user2)

    assert_no_difference('Vote.count') do
      post :create, motion_id: motions(:one), for: :neutral, format: :js
    end

    assert_response 304
    assert assigns(:motion)
    assert assigns(:vote)
  end

end
