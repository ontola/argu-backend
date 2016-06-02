require 'test_helper'

class NotificationSchedulerWorkersTest < ActiveSupport::TestCase
  let(:activity) do
    create(:activity,
           :t_argument,
           trackable: argument,
           forum: argument.forum)
  end

  let!(:argument) { create(:argument) }

  let!(:follow) do
    create(:follow,
           :t_argument,
           followable: argument.edge,
           follower: follower)
  end

  let!(:follower) { create :user, :viewed_notifications_hour_ago, :follows_email }

  let!(:follower_weekly) { create :user, :viewed_notifications_hour_ago, :follows_email_weekly }

  let!(:follower_been_mailed) { create :user, :viewed_notifications_now, :follows_email }

  def create_notification_pair_for(user)
    create(:notification,
           activity: activity,
           user: user,
           created_at: 2.minutes.ago)

    create(:notification,
           activity: activity,
           user: user,
           created_at: 1.day.ago)
  end

  test 'should collect direct followers to send notificaitons' do
    create_notification_pair_for follower
    create_notification_pair_for follower_weekly

    worker = DirectNotificationsSchedulerWorker.new
    user_ids = worker.collect_user_ids
    assert_equal 1, user_ids.count
    assert_equal follower.id, user_ids.first
  end

  test 'should collect weekly followers to send notifications' do
    create_notification_pair_for follower
    create_notification_pair_for follower_weekly

    worker = WeeklyNotificationsSchedulerWorker.new
    user_ids = worker.collect_user_ids
    assert_equal 1, user_ids.count
    assert_equal follower_weekly.id, user_ids.first
  end

  test 'should not collect followers that has been mailed already' do
    create_notification_pair_for follower_been_mailed

    worker = DirectNotificationsSchedulerWorker.new
    user_ids = worker.collect_user_ids
    assert_not user_ids.include?(follower_been_mailed)
  end
end
