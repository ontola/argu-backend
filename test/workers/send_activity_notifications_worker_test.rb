# frozen_string_literal: true

require 'test_helper'

class SendActivityNotificationsWorkerTest < ActiveSupport::TestCase
  define_freetown
  let!(:motion) { create(:motion, parent: freetown.edge) }
  let!(:argument) { create(:argument, parent: motion.edge) }

  let!(:follow) do
    create(:follow,
           followable: argument.edge,
           follower: follower)
  end

  let!(:follower) { create :user, :viewed_notifications_hour_ago, :follows_reactions_directly }

  let!(:follower_daily) { create :user, :viewed_notifications_hour_ago, :follows_reactions_daily }
  let!(:follower_weekly) { create :user, :viewed_notifications_hour_ago, :follows_reactions_weekly }

  test 'should send mail to direct follower' do
    create_notification_pair_for follower
    notification_email_mock(follower)

    snw = SendActivityNotificationsWorker.new
    snw.instance_variable_set(:@user, follower)
    assert_equal 1, snw.send(:collect_activity_notifications).length

    email_type = User.reactions_emails[:direct_reactions_email]
    snw.perform(follower.id, email_type)

    assert_email_sent(skip_sidekiq: true)

    follower.reload
    assert_equal 0, snw.send(:collect_activity_notifications).length, 'Notifications will be send twice'
  end

  test 'should send mail to daily follower' do
    create_notification_pair_for follower_daily
    notification_email_mock(follower_daily)

    snw = SendActivityNotificationsWorker.new
    snw.instance_variable_set(:@user, follower_daily)
    assert_equal 1, snw.send(:collect_activity_notifications).length

    email_type = User.reactions_emails[:daily_reactions_email]
    snw.perform(follower_daily.id, email_type)

    assert_email_sent(skip_sidekiq: true)

    follower_daily.reload
    assert_equal 0, snw.send(:collect_activity_notifications, follower_daily).length, 'Notifications will be send twice'
  end

  test 'should send mail to weekly follower' do
    create_notification_pair_for follower_weekly
    notification_email_mock(follower_weekly)

    snw = SendActivityNotificationsWorker.new
    snw.instance_variable_set(:@user, follower_weekly)
    assert_equal 1, snw.send(:collect_activity_notifications).length

    email_type = User.reactions_emails[:weekly_reactions_email]
    snw.perform(follower_weekly.id, email_type)

    assert_email_sent(skip_sidekiq: true)

    follower_weekly.reload
    assert_equal 0,
                 snw.send(:collect_activity_notifications, follower_weekly).length, 'Notifications will be send twice'
  end

  test 'should send multiple notifications as a digest' do
    create_list :notification, 10,
                activity: argument.activities.first,
                user: follower
    create_list :notification, 10,
                activity: argument.activities.first,
                user: follower,
                created_at: Time.current - 1.day
    notification_email_mock(follower)

    snw = SendActivityNotificationsWorker.new
    snw.instance_variable_set(:@user, follower)
    assert_equal 10, snw.send(:collect_activity_notifications).length

    email_type = User.reactions_emails[:direct_reactions_email]
    snw.perform(follower.id, email_type)

    assert_email_sent(skip_sidekiq: true)

    follower.reload
    assert_equal 0, snw.send(:collect_activity_notifications, follower).length, 'Notifications will be send twice'
  end

  test 'should not send direct mail to weekly follower' do
    create_notification_pair_for follower_weekly

    email_type = User.reactions_emails[:direct_reactions_email]
    Sidekiq::Testing.inline! do
      SendActivityNotificationsWorker.perform_async(follower_weekly.id, email_type)
    end
  end

  test 'should not send weekly mail to direct follower' do
    create_notification_pair_for follower

    email_type = User.reactions_emails[:weekly_reactions_email]
    Sidekiq::Testing.inline! do
      SendActivityNotificationsWorker.perform_async(follower.id, email_type)
    end
  end

  private

  def create_notification_pair_for(user)
    create(:notification,
           activity: argument.activities.first,
           user: user)

    create(:notification,
           activity: argument.activities.first,
           user: user,
           created_at: 1.day.ago)
  end

  def notification_email_mock(user)
    create_email_mock(
      'activity_notifications',
      user.email,
      follows: [
        {
          notifications: WebMock::Matchers::AnyArgMatcher.new(false),
          follow_id: nil,
          followable: {display_name: motion.display_name, id: motion.context_id, pro: nil, type: 'Motion'},
          organization: {display_name: motion.forum.page.display_name}
        }
      ]
    )
  end
end
