# frozen_string_literal: true

json.notifications do
  json.unread @unread
  json.lastNotification @notifications.first&.created_at
  json.from_time @from_time
  json.notifications @notifications do |notification|
    json.id notification.id
    json.display_name notification.display_name
    json.created_at notification.created_at
    json.url url_for(notification.url_object.to_s)
    json.permanent notification.permanent
    json.read notification.read_at.present?
    json.read_at notification.read_at
    json.creator do
      json.avatar do
        json.url notification.image
      end
    end
  end
end
