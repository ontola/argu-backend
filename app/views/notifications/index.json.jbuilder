json.notifications do
  json.unread @unread
  json.lastNotification @notifications.first.created_at
  json.notifications @notifications do |notification|
    json.id notification.id
    json.title notification.activity.trackable.display_name
    json.url url_for(notification.activity.trackable)
    json.read notification.read_at.present?
    json.read_at notification.read_at
  end
end