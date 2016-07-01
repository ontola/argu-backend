# frozen_string_literal: true

class PublishedCreateService < EdgeableCreateService
  # @note Call super when overriding.
  def initialize(parent, attributes: {}, options: {})
    attributes[:publisher] = options.fetch(:publisher)
    attributes[:creator] = options.fetch(:creator)
    super
  end

  private

  def after_save
    super
    if resource.respond_to?(:is_published?) && resource.argu_publication&.published_at.nil?
      resource.publisher.update(has_drafts: true)
    end
    resource.publisher.follow(resource.edge)
    resource.edge.ancestors.where(owner_type: %w(Motion Question Project)).each do |ancestor|
      current_follow_type = resource.publisher.following_type(ancestor)
      if Follow.follow_types[:news] > Follow.follow_types[current_follow_type]
        resource.publisher.follow(ancestor, :news)
      end
    end
  end
end
