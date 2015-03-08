module NotificationsHelper

  def notifications_for(user, page)
    _notifications = policy_scope(user.profile.notifications).includes(activity: :trackable).order(created_at: :desc).page(page)
    _notifications.map { |n| {id: n.id, title: n.activity.trackable.display_name, url: url_for(n.activity.trackable), read: n.read_at.present?, created_at: n.created_at} }
  end
end
