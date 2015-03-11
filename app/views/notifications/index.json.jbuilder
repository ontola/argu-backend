json.notifications do
  json.unread @unread
  json.lastNotification @notifications.first && @notifications.first.created_at
  json.notifications @notifications do |notification|
    json.id notification.id
    json.title activity_string_for(notification.activity)
    json.url url_for(notification.activity.trackable)
    json.read notification.read_at.present?
    json.read_at notification.read_at
  end
end