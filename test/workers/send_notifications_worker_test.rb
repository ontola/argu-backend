# frozen_string_literal: true
require 'test_helper'

class SendNotificationsWorkerTest < ActiveSupport::TestCase
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

  def create_notification_pair_for(user)
    create(:notification,
           activity: argument.activities.first,
           user: user)

    create(:notification,
           activity: argument.activities.first,
           user: user,
           created_at: 1.day.ago)
  end

  test 'should send mail to direct follower' do
    create_notification_pair_for follower

    snw = SendNotificationsWorker.new
    assert_equal 1, snw.collect_notifications(follower).length

    email_type = User.reactions_emails[:direct_reactions_email]
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      Sidekiq::Testing.inline! do
        SendNotificationsWorker.perform_async(follower.id, email_type)
      end
    end

    follower.reload
    assert_equal 0, snw.collect_notifications(follower).length, 'Notifications will be send twice'
  end

  test 'should send mail to daily follower' do
    create_notification_pair_for follower_daily

    snw = SendNotificationsWorker.new
    assert_equal 1, snw.collect_notifications(follower_daily).length

    email_type = User.reactions_emails[:daily_reactions_email]
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      Sidekiq::Testing.inline! do
        SendNotificationsWorker.perform_async(follower_daily.id, email_type)
      end
    end

    follower_daily.reload
    assert_equal 0, snw.collect_notifications(follower_daily).length, 'Notifications will be send twice'
  end

  test 'should send mail to weekly follower' do
    create_notification_pair_for follower_weekly

    snw = SendNotificationsWorker.new
    assert_equal 1, snw.collect_notifications(follower_weekly).length

    email_type = User.reactions_emails[:weekly_reactions_email]
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      Sidekiq::Testing.inline! do
        SendNotificationsWorker.perform_async(follower_weekly.id, email_type)
      end
    end

    follower_weekly.reload
    assert_equal 0, snw.collect_notifications(follower_weekly).length, 'Notifications will be send twice'
  end

  test 'should send multiple notifications as a digest' do
    create_list :notification, 10,
                activity: argument.activities.first,
                user: follower
    create_list :notification, 10,
                activity: argument.activities.first,
                user: follower,
                created_at: Time.current - 1.day

    snw = SendNotificationsWorker.new
    assert_equal 10, snw.collect_notifications(follower).length

    email_type = User.reactions_emails[:direct_reactions_email]
    assert_difference 'ActionMailer::Base.deliveries.count', 1, "ActionMailer doesn't send in bulk" do
      Sidekiq::Testing.inline! do
        SendNotificationsWorker.perform_async(follower.id, email_type)
      end
    end

    follower.reload
    assert_equal 0, snw.collect_notifications(follower).length, 'Notifications will be send twice'
  end

  test 'should not send direct mail to weekly follower' do
    create_notification_pair_for follower_weekly

    email_type = User.reactions_emails[:direct_reactions_email]
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      Sidekiq::Testing.inline! do
        SendNotificationsWorker.perform_async(follower_weekly.id, email_type)
      end
    end
  end

  test 'should not send weekly mail to direct follower' do
    create_notification_pair_for follower

    email_type = User.reactions_emails[:weekly_reactions_email]
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      Sidekiq::Testing.inline! do
        SendNotificationsWorker.perform_async(follower.id, email_type)
      end
    end
  end
end
