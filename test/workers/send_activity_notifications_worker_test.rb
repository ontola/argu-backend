# frozen_string_literal: true

require 'test_helper'

class SendActivityNotificationsWorkerTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
  define_freetown
  let!(:motion) { create(:motion, parent: freetown) }
  let!(:argument) { create(:argument, parent: motion) }

  let!(:follow) do
    create(:follow,
           followable: argument,
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
    assert_equal 0, snw.send(:collect_activity_notifications).length, 'Notifications will be send twice'
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
                 snw.send(:collect_activity_notifications).length, 'Notifications will be send twice'
  end

  test 'should send multiple notifications as a digest' do
    create_list :notification, 10,
                activity: argument.activities.last,
                root_id: argument.root_id,
                user: follower
    create_list :notification, 10,
                activity: argument.activities.last,
                root_id: argument.root_id,
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
    assert_equal 0, snw.send(:collect_activity_notifications).length, 'Notifications will be send twice'
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
    [Time.current, 1.day.ago].each do |created_at|
      create(:notification,
             created_at: created_at,
             activity: argument.activities.last,
             root_id: argument.root_id,
             user: user)
    end

    create(:follow,
           followable: argument.activities.last.recipient,
           follower: user)
  end

  def notification_email_mock(user)
    create_email_mock(
      'activity_notifications',
      user.email,
      follows: [
        {
          notifications: WebMock::Matchers::AnyArgMatcher.new(false),
          follow_id: user.follow_for(motion)&.unsubscribe_iri,
          followable: {display_name: motion.display_name, id: motion.iri, pro: nil, type: 'Motion'},
          organization: {display_name: motion.root.display_name}
        }
      ]
    )
  end
end
