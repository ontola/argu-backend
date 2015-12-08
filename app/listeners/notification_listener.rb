class NotificationListener

  def create_activity_successful(activity)
    create_notifications_for(activity, activity.recipient.followers)
  end

  private

  def create_notifications_for(activity, followers)
    notifications = collect_followers_for(activity, followers)
    Notification.create!([notifications])
  end

  def collect_followers_for(activity, followers)
    followers
        .reject { |f| f.profile == activity.owner }
        .map { |f| {user: f, activity: activity} }
  end
end
