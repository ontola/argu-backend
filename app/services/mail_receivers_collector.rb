class MailReceiversCollector
  def initialize(email_frequency)
    @email_frequency = email_frequency
  end

  def call
    t_notifications = Notification.arel_table
    t_users = User.arel_table
    User.where.not(confirmed_at: nil)
      .joins(:notifications)
      .where(t_notifications[:read_at].eq(nil))
      .where(t_users[:notifications_viewed_at].eq(nil)
               .or(t_users[:notifications_viewed_at].lt(t_notifications[:created_at])))
      .where(t_notifications[:notification_type].eq(Notification.notification_types[:reaction])
               .and(t_users[:reactions_email].eq(@email_frequency))
               .or(t_notifications[:notification_type].eq(Notification.notification_types[:news])
                     .and(t_users[:news_email].eq(@email_frequency)))
               .or(t_notifications[:notification_type].eq(Notification.notification_types[:decision])
                     .and(t_users[:decisions_email].eq(@email_frequency))))
      .where.not(t_notifications[:activity_id].eq(nil))
      .select('DISTINCT users.id')
      .map(&:id)
  end
end
