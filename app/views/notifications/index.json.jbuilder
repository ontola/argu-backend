json.notifications do
  json.unread @unread
  json.lastNotification @notifications.first && @notifications.first.created_at
  json.notifications @notifications do |notification|
    json.id notification.id
    parent = (notification.activity.trackable.try(:parent) && notification.activity.trackable.parent) || notification.activity.recipient
    json.title "#{notification.activity.owner.display_name} #{t("activities.#{notification.activity.trackable.class_name}.create#{'_your' if parent.creator == current_user.profile}", thing: t("#{parent.class_name}.type"))}"
    json.url url_for(notification.activity.trackable)
    json.read notification.read_at.present?
    json.read_at notification.read_at
  end
end