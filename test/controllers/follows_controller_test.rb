require 'test_helper'

class FollowsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:freetown) { create(:forum) }
  let(:motion) do
    create :motion,
           forum: freetown
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not post create' do
    motion_referer
    post :create,
         gid: motion.edge.id,
         follow_type: :reactions,
         format: :json

    assert_redirected_to motion_path(motion)
  end

  test 'guest should not delete destroy' do
    motion_referer
    post :create,
         gid: motion.edge.id,
         follow_type: :reactions,
         format: :json

    assert_redirected_to motion_path(motion)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should post create' do
    motion_referer
    sign_in user

    post :create,
         gid: motion.edge.id,
         follow_type: :reactions,
         format: :json

    assert_response 201
  end

  test 'user should delete destroy' do
    motion_referer
    sign_in user

    delete :destroy,
           gid: motion.edge.id,
           follow_type: :reactions,
           format: :json

    assert_response 204
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should post create' do
    motion_referer
    sign_in member

    post :create,
         gid: motion.edge.id,
         follow_type: :reactions,
         format: :json

    assert_response 201
  end

  test 'member should delete destroy' do
    motion_referer
    sign_in member

    delete :destroy,
           gid: motion.edge.id,
           follow_type: :reactions,
           format: :json

    assert_response 204
  end

  private

  def motion_referer
    request.env["HTTP_REFERER"] = motion_path(motion)
  end
end
