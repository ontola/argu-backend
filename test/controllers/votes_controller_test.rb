require "test_helper"

class VotesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should post create" do
    sign_in users(:user)

    assert_difference('Vote.count') do
      post :create, motion_id: motions(:one), for: :pro, format: :js
    end

    assert_response :success
    assert assigns(:model)
    assert assigns(:vote)
  end

  test "should not create new vote when existing one is present" do
    sign_in users(:user2)

    assert_no_difference('Vote.count') do
      post :create, motion_id: motions(:one), for: :neutral, format: :js
    end

    assert_response 304
    assert assigns(:model)
    assert assigns(:vote)
  end
end
