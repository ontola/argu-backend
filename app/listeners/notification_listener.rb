class NotificationListener
  def create_activity_successful(activity)
    create_notifications_for(activity, collect_followers_for(activity)) if activity.action == 'create'
  end

  private

  def create_notifications_for(activity, followers)
    Notification.create!(prepare_followers(activity, followers))
  end

  def collect_followers_for(activity)
    activity.recipient.followers
        .reject { |f| f.profile == activity.owner }
  end

  # @return [Array<Hash{Symbol => User, Symbol => Activity}>] List of attributes for {Notification} creation
  def prepare_followers(activity, followers)
    followers
        .map { |f| {user: f, activity: activity} }
  end
end
