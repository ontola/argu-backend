# frozen_string_literal: true
class NotificationListener
  def create_activity_successful(activity)
    create_notifications_for(activity) if create_notifications_for_activity?(activity)
  end

  def update_successful(resource)
    if resource.is_publishable? &&
        resource.is_published? &&
        resource.edge.argu_publication.previous_changes.include?('follow_type') &&
        resource.edge.argu_publication.news?
      activity = resource.edge.activities.find_by("key ~ '*.publish'")
      create_notifications_for(activity) if activity
    end
  end

  private

  def create_notifications_for_activity?(activity)
    activity.new_content? || activity.action == 'trash'
  end

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
