json.notifications do
  json.unreadCount @unread
  json.page params[:page] || 1
  json.lastNotification @notifications.first && @notifications.first.created_at
  json.from_time @from_time
  json.notifications @notifications do |notification|
    json.id notification.id
    json.title notification.title
    json.created_at notification.created_at
    json.url url_for(notification.url_object)
    json.read notification.read_at.present?
    json.read_at notification.read_at
    json.creator do
      json.avatar do
        json.url notification.image
      end
    end
  end
end
