module NotificationsHelper

  def notifications_for(user, page)
    _notifications = policy_scope(user.profile.notifications).includes(activity: :trackable).order(created_at: :desc).page(page)
    _notifications.map do |n|
      parent = (n.activity.trackable.try(:parent) && n.activity.trackable.parent) || n.activity.recipient
      title = "#{n.activity.owner.display_name} #{t("activities.#{n.activity.trackable.class_name}.create#{'_your' if parent.creator == current_user.profile}", thing: t("#{parent.class_name}.type"))}"
      { id: n.id, title: title, url: url_for(n.activity.trackable), read: n.read_at.present?, created_at: n.created_at, creator: {avatar: {url: n.activity.owner.profile_photo.url(:avatar)}} }
    end
  end
end
