require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:motion) { FactoryGirl.create(:motion) }

  ####################################
  # As user
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should post create' do
    sign_in users(:user)

    assert_difference('Vote.count', 1) do
      post :create, motion_id: motions(:one), for: :pro, format: :json
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:vote)
  end

  test 'should not create new vote when existing one is present' do
    sign_in users(:user2)

    assert_no_difference('Vote.count') do
      post :create, motion_id: motions(:one), for: :neutral, format: :js
    end

    assert_response 304
    assert assigns(:model)
    assert assigns(:vote)
  end

  test 'should delete destroy own vote' do
    sign_in users(:user)

    assert_difference('Vote.count', -1) do
      delete :destroy, id: votes(:three).id, format: :json
    end

    assert_response 204
  end

  test "should not delete destroy others' vote" do
    sign_in users(:user)

    assert_no_difference('Vote.count') do
      delete :destroy, id: votes(:one).id, format: :json
    end

    assert_response 403
  end

  test 'should 403 when not a member' do
    sign_in user

    post :create, motion_id: motion, for: :pro, format: :json

    assert_response 403
  end
end
