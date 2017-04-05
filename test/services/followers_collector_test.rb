# frozen_string_literal: true
require 'test_helper'

class FollowersCollectorTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:important_motion) { create(:motion, parent: freetown.edge, mark_as_important: '1') }
  let(:activity) { project.activities.first }
  let!(:news_follow) { create(:news_follow, followable: freetown.edge) }

  test 'should collect 0 for motion in unfollowed forum' do
    Follow.destroy_all
    assert_equal 0, FollowersCollector.new(activity: motion.activities.first).count
  end

  test 'should collect reaction followers for motion' do
    assert_equal 1, FollowersCollector.new(activity: motion.activities.first).count
  end

  test 'should collect news followers for motion with marked_as_important' do
    assert_equal 2, FollowersCollector.new(activity: important_motion.activities.first).count
  end
end
