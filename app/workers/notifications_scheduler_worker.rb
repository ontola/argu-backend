# frozen_string_literal: true
class NotificationsSchedulerWorker
  def send_batch_notifications(email_frequency)
    user_ids = BatchNotificationsReceiversCollector.new(email_frequency).call
    logger.info 'No batch notifications to be sent' if user_ids.blank?
    user_ids.each do |user_id|
      SendBatchNotificationsWorker.perform_async(user_id, email_frequency)
      logger.info "Scheduled a job to send notifications to user #{user_id}"
    end
  end
end
