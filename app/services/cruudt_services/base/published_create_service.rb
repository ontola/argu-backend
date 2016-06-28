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
    resource.publisher.follow(resource.edge, :reactions, :news)
  end
end
