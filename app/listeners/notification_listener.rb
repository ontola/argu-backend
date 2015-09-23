class NotificationListener

  def create_activity_successful(activity)
    create_notifications_for(activity, activity.trackable.followers)
  end

private

  def create_notifications_for(activity, followers)
    notifications = followers.map { |f| {user: f, activity: activity}  }
    Notification.create([notifications])
  end
end
