require 'test_helper'

class FollowsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_common_objects :freetown, :user, :member, :motion

  ####################################
  # As Guest
  ####################################
  test 'guest should not post create' do
    motion_referer
    post :create,
         motion_id: motion,
         format: :json

    assert_redirected_to motion_path(motion)
  end

  test 'guest should not delete destroy' do
    motion_referer
    post :create,
         motion_id: motion,
         format: :json

    assert_redirected_to motion_path(motion)
  end

  ####################################
  # As User
  ####################################
  test 'user should post create' do
    motion_referer
    sign_in user

    post :create,
         motion_id: motion,
         format: :json

    assert_response 201
  end

  test 'user should delete destroy' do
    motion_referer
    sign_in user

    delete :destroy,
           motion_id: motion,
           format: :json

    assert_response 204
  end

  ####################################
  # As Member
  ####################################
  test 'member should post create' do
    motion_referer
    sign_in member

    post :create,
         motion_id: motion,
         format: :json

    assert_response 201
  end

  test 'member should delete destroy' do
    motion_referer
    sign_in member

    delete :destroy,
           motion_id: motion,
           format: :json

    assert_response 204
  end

  private

  def motion_referer
    request.env["HTTP_REFERER"] = motion_path(motion)
  end
end
