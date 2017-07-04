# frozen_string_literal: true
class DailyNotificationsSchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }
  EMAIL_FREQUENCY = User.reactions_emails[:daily_reactions_email]

  def perform
    user_ids = BatchNotificationsReceiversCollector.new(EMAIL_FREQUENCY).call

    logger.info 'No notifications to be sent' if user_ids.blank?
    user_ids.each do |user_id|
      SendBatchNotificationsWorker.perform_async(user_id, EMAIL_FREQUENCY)
      logger.info "Scheduled a job to send notifications to user #{user_id}"
    end
  end
end
