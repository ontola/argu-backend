module NotificationsHelper

  def notifications_for(user, page)
    _notifications = policy_scope(user.profile.notifications).includes(activity: :trackable).order(created_at: :desc).page(page)
    _notifications.map do |n|
      { id: n.id, title: activity_string_for(n.activity), url: url_for(n.activity.trackable), read: n.read_at.present?, created_at: n.created_at, creator: {avatar: {url: n.activity.owner.profile_photo.url(:avatar)}} }
    end
  end

end
