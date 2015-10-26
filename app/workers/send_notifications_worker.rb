class SendNotificationsWorker
  include Sidekiq::Worker

  COOLDOWN_PERIOD = 4.minutes

  def perform(user_id, delivery_type)
    user = User.find(user_id)

    unless user.confirmed_at.present?
      logger.warn "Not sending notifications to unconfirmed email #{user.email}"
      return
    end

    unless delivery_type.present? && User.follows_emails[user.follows_email] == delivery_type
      logger.warn "Not sending notifications to mismatched delivery type #{delivery_type} for user #{user.id}"
      return
    end

    t_notifications = Notification.arel_table
    ActiveRecord::Base.transaction do
      notifications = user.notifications
                          .where(t_notifications[:read_at]
                                     .eq(nil)
                                     .and(t_notifications[:created_at]
                                              .gt(user.notifications_viewed_at)))
                          .order(created_at: :desc)
                          .lock('FOR UPDATE NOWAIT')

      if notifications.length == 0
        logger.warn 'No notifications to send'
      else
        logger.info "Preparing to possibly send #{notifications.length} notifications"
      end
      last_viewed = user.reload.notifications_viewed_at
      if notifications.length > 0 && (last_viewed.blank? || last_viewed && (last_viewed < (Time.current - COOLDOWN_PERIOD)))
        logger.info "Sending #{notifications.length} notification(s) to #{user.email}"
        NotificationsMailer.notifications_email(user, notifications).deliver
        user.update(notifications_viewed_at: Time.current)
      end
    end
  rescue PG::LockNotAvailable => e
    logger.error 'Queue collision occurred'
    logger.error e
    Bugsnag.auto_notify(e) if Rails.env.production?
  end
end
