# frozen_string_literal: true

module NotificationsHelper
  def unread_notification_count
    policy_scope(Notification)
      .where('read_at is NULL')
      .count
  end
end
