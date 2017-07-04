# frozen_string_literal: true
class DailyNotificationsSchedulerWorker < NotificationsSchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    send_batch_notifications(User.reactions_emails[:daily_reactions_email])
  end
end
