# frozen_string_literal: true
class NotificationListener
  def create_activity_successful(activity)
    case activity.object
    when 'vote', 'banner'
      nil
    when 'blog_post', 'project', 'motion', 'question'
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
                   .new(activity: activity)
                   .call
                   .to_a
    if activity.trackable_type == 'Decision'
      forwarded_to = activity.trackable.forwarded_user
      if forwarded_to.present? && !recipients.include?(forwarded_to) && forwarded_to != activity.owner.profileable
        recipients << forwarded_to
      end
    end
    Notification.create!(prepare_recipients(activity, recipients))
  end

  # @return [Array<Hash{Symbol => User, Symbol => Activity}>] List of attributes for {Notification} creation
  def prepare_recipients(activity, recipients)
    recipients
      .uniq
      .map { |f| {user: f, activity: activity} }
  end
end
