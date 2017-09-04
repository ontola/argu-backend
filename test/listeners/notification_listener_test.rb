# frozen_string_literal: true

require 'test_helper'

class NotificationListenerTest < ActiveSupport::TestCase
  subject { NotificationListener.new }
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let!(:motion_activity) { motion.activities.second }
  let(:news_motion) do
    create(:motion, parent: freetown.edge, mark_as_important: '1')
  end
  let!(:news_motion_activity) { news_motion.activities.second }
  let!(:vote_activity) do
    create(
      :activity,
      trackable: create(:vote, parent: motion.default_vote_event.edge),
      forum: motion.forum
    )
  end

  test 'should create notification on motion activity' do
    Notification.destroy_all
    assert_difference('Notification.count', 1) do
      subject.create_activity_successful(motion_activity)
    end
    assert_equal 'reaction', Notification.last.notification_type

    assert_difference('Notification.count', 2) do
      update_resource(motion, mark_as_important: '1')
    end
    assert_equal 'news', Notification.last.notification_type
  end

  test 'should create notification on news motion activity' do
    Notification.destroy_all
    # Create notifications for the follower and the creators of the vote and the motion
    assert_difference('Notification.count', 3) do
      subject.create_activity_successful(news_motion_activity)
    end
    assert_equal 'news', Notification.last.notification_type
  end

  test 'should not create notifications for votes' do
    Notification.destroy_all
    assert_difference('Notification.count', 0) do
      subject.create_activity_successful(vote_activity)
    end
  end
end
