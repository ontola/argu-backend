class DirectNotificationsSchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely }
  EMAIL_TYPE = User.follows_emails[:direct_follows_email]

  def perform
    user_ids = collect_user_ids

    logger.info 'No notifications to be sent' if user_ids.blank?
    user_ids.each do |user_id|
      SendNotificationsWorker.perform_async(user_id, EMAIL_TYPE)
      logger.info "Scheduled a job to send notifications to user #{user_id}"
    end
  end

  def collect_user_ids
    t_notifications = Notification.arel_table
    User.where.not(confirmed_at: nil)
        .where(follows_email: EMAIL_TYPE)
        .joins(:notifications)
        .where(t_notifications[:read_at]
                   .eq(nil))
        .select('DISTINCT users.id')
        .map(&:id)
  end
end
