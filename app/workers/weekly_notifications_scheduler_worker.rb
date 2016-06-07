class WeeklyNotificationsSchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely }
  EMAIL_FREQUENCY = User.reactions_emails[:weekly_reactions_email]

  def perform
    user_ids = MailReceiversCollector.new(EMAIL_FREQUENCY).call

    logger.info 'No notifications to be sent' if user_ids.blank?
    user_ids.each do |user_id|
      SendNotificationsWorker.perform_async(user_id, EMAIL_FREQUENCY)
      logger.info "Scheduled a job to send notifications to user #{user_id}"
    end
  end
end
