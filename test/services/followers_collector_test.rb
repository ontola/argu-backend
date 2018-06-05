# frozen_string_literal: true

require 'test_helper'

class FollowersCollectorTest < ActiveSupport::TestCase
  define_cairo
  let(:creator) { create_initiator(cairo) }
  let(:motion) { create(:motion, parent: cairo, publisher: creator) }
  let(:important_motion) { create(:motion, parent: cairo, publisher: creator, mark_as_important: '1') }
  let(:argument) { create(:argument, parent: motion, publisher: creator) }
  let(:activity) { motion.activities.first }
  let!(:news_follow) { create(:news_follow, followable: cairo, follower: create_initiator(cairo)) }
  let!(:granted_follower) { create(:follow, followable: cairo, follower: create_initiator(cairo)) }
  let!(:non_granted_follower) { create(:follow, followable: cairo, follower: create(:user)) }
  let!(:lower_granted_follower) { create(:follow, followable: cairo, follower: create_initiator(argument)) }

  test 'should collect 0 for motion in unfollowed forum' do
    Follow.destroy_all
    motion
    Notification.destroy_all
    assert_equal 0, FollowersCollector.new(activity: motion.activities.second).count
  end

  test 'should not collect notified followers for motion' do
    motion
    assert_equal 0, FollowersCollector.new(activity: motion.activities.second).count
  end

  test 'should collect reaction followers for motion' do
    motion
    Notification.destroy_all
    assert_equal 1, FollowersCollector.new(activity: motion.activities.second).count
  end

  test 'should not collect notified followers for motion with marked_as_important' do
    important_motion
    assert_equal 0, FollowersCollector.new(activity: important_motion.activities.second).count
  end

  test 'should collect reaction and news followers for motion with marked_as_important' do
    important_motion
    Notification.destroy_all
    assert_equal 2, FollowersCollector.new(activity: important_motion.activities.second).count
  end
end
