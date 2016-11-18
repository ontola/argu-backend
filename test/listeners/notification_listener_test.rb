# frozen_string_literal: true
require 'test_helper'

class NotificationListenerTest < ActiveSupport::TestCase
  subject { NotificationListener.new }
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let!(:motion_activity) { motion.activities.second }
  let!(:vote_activity) do
    create(
      :activity,
      trackable: create(:vote, parent: motion.edge),
      forum: motion.forum
    )
  end

  test 'should create notification on activity' do
    assert_difference('Notification.count', 1) do
      subject.create_activity_successful(motion_activity)
    end
  end

  test 'should not create notifications for votes' do
    assert_difference('Notification.count', 0) do
      subject.create_activity_successful(vote_activity)
    end
  end
end
