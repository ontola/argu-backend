# frozen_string_literal: true

module NotificationsHelper
  def unread_notification_count
    Pundit.policy_scope(user_context, Notification)
      .where('read_at is NULL')
      .count
  end
end
