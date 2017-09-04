# frozen_string_literal: true

require 'test_helper'

class FollowsControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) do
    create :motion,
           parent: freetown.edge
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not post create' do
    motion_referer
    post :create,
         params: {
           gid: motion.edge.id,
           follow_type: :reactions,
           format: :json
         }

    assert_redirected_to motion_path(motion)
    assert_analytics_not_collected
  end

  test 'guest should not delete destroy' do
    motion_referer
    post :create,
         params: {
           gid: motion.edge.id,
           follow_type: :reactions,
           format: :json
         }

    assert_redirected_to motion_path(motion)
    assert_analytics_not_collected
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should post create' do
    motion_referer
    sign_in user

    post :create,
         params: {
           gid: motion.edge.id,
           follow_type: :reactions,
           format: :json
         }

    assert_response 201
    assert_analytics_collected('follows', 'reactions', 'motions')
  end

  test 'user should delete destroy' do
    motion_referer
    sign_in user

    delete :destroy,
           params: {
             gid: motion.edge.id,
             follow_type: :reactions,
             format: :json
           }

    assert_response 204
    assert_analytics_collected('follows', 'reactions', 'motions')
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should post create' do
    motion_referer
    sign_in member

    post :create,
         params: {
           gid: motion.edge.id,
           follow_type: :news,
           format: :json
         }

    assert_response 201
    assert_analytics_collected('follows', 'news', 'motions')
  end

  test 'member should delete destroy' do
    motion_referer
    sign_in member

    delete :destroy,
           params: {
             gid: motion.edge.id,
             follow_type: :reactions,
             format: :json
           }

    assert_response 204
    assert_analytics_collected('follows', 'reactions', 'motions')
  end

  private

  def motion_referer
    request.env['HTTP_REFERER'] = motion_path(motion)
  end
end
