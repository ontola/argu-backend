class NotificationListener
  def create_activity_successful(activity)
    case activity.object
    when 'blog_post', 'project'
      create_notifications_for(activity) if activity.action == 'publish'
    else
      create_notifications_for(activity) if activity.action == 'create'
    end
  end

  private

  def create_notifications_for(activity)
    Notification.create!(FollowersCollector.new(activity).call)
  end
end
