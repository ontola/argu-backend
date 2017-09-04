# frozen_string_literal: true

class FollowersCollector
  # Collects the followers of the resource with follow_type or higher
  # @param resource [ActiveRecord::Base] The resource to collect the followers from
  # @param follow_type [Symbol] Any symbol of Follow.follow_types
  # @return [ActiveRecord::Relation] List of uniq Users, with a Follow of follow_type or higher for the resource
  def initialize(activity: nil, follow_type: nil, resource: nil)
    @activity = activity
    @follow_type = follow_type || activity.follow_type
    @resource = resource || (activity.new_content? ? activity.recipient : activity.trackable)
  end

  delegate :count, to: :followers

  def call
    followers.includes(:profile)
  end

  private

  def followers
    User
      .joins(follows: :followable, profile: {grants: :edge})
      .where(edges: {id: @resource.edge.id})
      .where('edges_grants.path @> ?', @resource.edge.path)
      .where(
        'users.id NOT IN (?)',
        (@activity&.notifications&.pluck(:user_id) || []).append(@activity&.audit_data.try(:[], 'user_id') || 0)
      )
      .where('follow_type >= ?', Follow.follow_types[@follow_type])
      .distinct
  end
end
