class WeeklyNotificationsSchedulerWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { weekly.day(:sunday) }
  EMAIL_TYPE = User.follows_emails[:weekly_follows_email]

  def perform
    t_notifications = Notification.arel_table
    user_ids = User.where.not(confirmed_at: nil)
                   .where(follows_email: EMAIL_TYPE)
                   .joins(:notifications)
                   .where(t_notifications[:read_at]
                            .eq(nil))
                   .select('DISTINCT users.id')
                   .map(&:id)

    user_ids.each do |user_id|
      SendNotificationsWorker.perform_async(user_id, EMAIL_TYPE)
      logger.info "Scheduled a job to send notifications to user #{user_id}"
    end
  end
end
