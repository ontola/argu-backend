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
    return if resource.store_in_redis?
    resource.publisher.follow(resource.edge, :reactions, :news)

    return if resource.try(:forum).nil? || resource.publisher.has_favorite?(resource.forum.edge)
    resource.publisher.favorites.create(edge: resource.forum.edge)
  end
end
