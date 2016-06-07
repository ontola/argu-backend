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
    recipients = FollowersCollector
                   .new(activity.recipient, follow_type(activity))
                   .call
                   .reject { |u| u.profile == activity.owner }
    Notification.create!(prepare_recipients(activity, recipients))
  end

  def follow_type(activity)
    case activity.trackable_type
    when 'BlogPost'
      :news
    else
      :reactions
    end
  end

  # @return [Array<Hash{Symbol => User, Symbol => Activity}>] List of attributes for {Notification} creation
  def prepare_recipients(activity, recipients)
    recipients
      .map { |f| {user: f, activity: activity} }
  end
end
