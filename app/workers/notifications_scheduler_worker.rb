# frozen_string_literal: true

class NotificationsSchedulerWorker
  def send_activity_notifications(email_frequency)
    user_ids = ActivityNotificationsReceiversCollector.new(email_frequency).call
    logger.info 'No batch notifications to be sent' if user_ids.blank?
    user_ids.each do |user_id|
      ActsAsTenant.with_tenant(Page.first) do
        SendActivityNotificationsWorker.perform_async(user_id, email_frequency)
      end
      logger.info "Scheduled a job to send notifications to user #{user_id}"
    end
  end
end
