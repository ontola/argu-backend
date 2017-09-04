# frozen_string_literal: true

class WeeklyNotificationsSchedulerWorker < NotificationsSchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { weekly }

  def perform
    send_batch_notifications(User.reactions_emails[:weekly_reactions_email])
  end
end
