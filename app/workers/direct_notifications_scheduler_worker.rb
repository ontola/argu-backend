# frozen_string_literal: true
class DirectNotificationsSchedulerWorker < NotificationsSchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely }

  def perform
    send_batch_notifications(User.reactions_emails[:direct_reactions_email])
  end
end
