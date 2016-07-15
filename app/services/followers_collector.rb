# frozen_string_literal: true
class FollowersCollector
  # Collects the followers of the resource with follow_type or higher
  # @param resource [ActiveRecord::Base] The resource to collect the followers from
  # @param follow_type [Symbol] Any symbol of Follow.follow_types
  # @return [ActiveRecord::Relation] List of uniq Users, with a Follow of follow_type or higher for the resource
  def initialize(resource, follow_type)
    @resource = resource
    @follow_type = follow_type
  end

  def call
    @resource
      .edge
      .followers(includes: {follower: :profile}, where: "follow_type >= #{Follow.follow_types[@follow_type]}")
      .uniq
  end
end
