# frozen_string_literal: true

require 'test_helper'

class FollowsControllerTest < ActionController::TestCase
  define_freetown
  define_cairo
  let(:motion) do
    create :motion,
           parent: freetown.edge
  end
  let(:cairo_motion) do
    create :motion,
           parent: cairo.edge
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not post create' do
    motion
    assert_no_difference('Follow.count') do
      post :create,
           params: {
             gid: motion.edge.id,
             follow_type: :reactions,
             format: :json
           }
    end

    assert_not_a_user
    assert_analytics_not_collected
  end

  test 'guest should not delete destroy' do
    motion
    assert_no_difference('Follow.count') do
      post :create,
           params: {
             gid: motion.edge.id,
             follow_type: :reactions,
             format: :json
           }
    end

    assert_not_a_user
    assert_analytics_not_collected
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should post create' do
    motion
    sign_in user
    assert_difference('Follow.count') do
      post :create,
           params: {
             gid: motion.edge.id,
             follow_type: :reactions,
             format: :json
           }
    end

    assert_response 201
    assert_analytics_collected('follows', 'reactions', 'motions')
  end

  test 'user should delete destroy' do
    create(:follow, followable: motion.edge, follower: user)
    sign_in user

    assert_differences([['Follow.count', 0], ['Follow.never.count', 1]]) do
      delete :destroy,
             params: {
               gid: motion.edge.id,
               follow_type: :reactions,
               format: :json
             }
    end

    assert_response 204
    assert_analytics_collected('follows', 'reactions', 'motions')
  end

  ####################################
  # As Non Member
  ####################################
  test 'non member should not post create' do
    cairo_motion
    sign_in user

    assert_no_difference('Follow.count') do
      post :create,
           params: {
             gid: cairo_motion.edge.id,
             follow_type: :reactions,
             format: :json
           }
    end

    assert_not_authorized
  end

  test 'non member should not delete destroy' do
    create(:follow, followable: cairo_motion.edge, follower: user)
    sign_in user

    assert_no_difference('Follow.count') do
      delete :destroy,
             params: {
               gid: cairo_motion.edge.id,
               follow_type: :reactions,
               format: :json
             }
    end

    assert_not_authorized
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should post create' do
    motion
    sign_in member

    assert_difference('Follow.count') do
      post :create,
           params: {
             gid: motion.edge.id,
             follow_type: :news,
             format: :json
           }
    end

    assert_response 201
    assert_analytics_collected('follows', 'news', 'motions')
  end

  test 'member should post update' do
    follow = create(:follow, followable: motion.edge, follower: member)
    sign_in member

    assert_equal follow.follow_type, 'reactions'
    assert_no_difference('Follow.count') do
      post :create,
           params: {
             gid: motion.edge.id,
             follow_type: :news,
             format: :json
           }
    end
    assert_equal follow.reload.follow_type, 'news'

    assert_response 201
    assert_analytics_collected('follows', 'news', 'motions')
  end

  test 'member should get show' do
    follow = create(:follow, followable: motion.edge, follower: member)
    sign_in member

    assert_equal follow.follow_type, 'reactions'
    assert_no_difference('Follow.count') do
      get :show, params: {id: follow.id}
    end
    assert_equal follow.reload.follow_type, 'never'

    assert_response 200
  end

  test 'member should delete destroy' do
    create(:follow, followable: motion.edge, follower: member)
    sign_in member

    assert_differences([['Follow.count', 0], ['Follow.never.count', 1]]) do
      delete :destroy,
             params: {
               gid: motion.edge.id,
               follow_type: :reactions,
               format: :json
             }
    end

    assert_response 204
    assert_analytics_collected('follows', 'reactions', 'motions')
  end
end
