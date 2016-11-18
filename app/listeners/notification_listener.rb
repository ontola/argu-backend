# frozen_string_literal: true
class NotificationListener
  def create_activity_successful(activity)
    case activity.object
    when 'vote', 'banner'
      nil
    when 'blog_post', 'project', 'motion'
      create_notifications_for(activity) if activity.action == 'publish'
    when 'decision'
      create_notifications_for(activity) unless %w(update create).include?(activity.action)
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
    if activity.trackable_type == 'Decision'
      forwarded_to_user = activity.trackable.forwarded_user
      if forwarded_to_user.present? &&
          !recipients.include?(forwarded_to_user) &&
          !(forwarded_to_user == activity.owner.profileable)
        recipients << forwarded_to_user
      end
    end
    Notification.create!(prepare_recipients(activity, recipients))
  end

  def follow_type(activity)
    case activity.trackable_type
    when 'BlogPost'
      :news
    when 'Decision'
      activity.trackable.forwarded? ? :reactions : :decisions
    else
      :reactions
    end
  end

  # @return [Array<Hash{Symbol => User, Symbol => Activity}>] List of attributes for {Notification} creation
  def prepare_recipients(activity, recipients)
    recipients
      .uniq
      .map { |f| {user: f, activity: activity} }
  end
end
