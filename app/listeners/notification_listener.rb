# frozen_string_literal: true

class NotificationListener
  def create_activity_failed(activity)
    raise "Creating #{activity.key} activity for #{activity.trackable_edge_id} failed: #{activity.errors.full_messages}"
  end

  def create_activity_successful(activity)
    create_notifications_for(activity) if create_notifications_for_activity?(activity)
  end

  def update_successful(resource)
    if resource.is_publishable? &&
        resource.is_published? &&
        resource.argu_publication.previous_changes.include?('follow_type') &&
        resource.argu_publication.news?
      activity = resource.activities.find_by("key ~ '*.publish'")
      create_notifications_for(activity) if activity
    end
  end

  private

  def create_notifications_for_activity?(activity)
    activity.new_content? || activity.notify
  end

  def create_notifications_for(activity)
    recipients = FollowersCollector.new(activity: activity).call.to_a
    if activity.trackable_type == 'Comment' && activity.trackable.parent_comment_id
      recipients.concat(
        FollowersCollector.new(activity: activity, resource: activity.trackable.reload.parent_comment).call.to_a
      )
    end
    Notification.create!(prepare_recipients(activity, recipients))
  end

  # @return [Array<Hash{Symbol => User, Symbol => Activity}>] List of attributes for {Notification} creation
  def prepare_recipients(activity, recipients)
    recipients
      .uniq
      .map { |f| {user: f, activity: activity, root_id: activity.root_id} }
  end
end
