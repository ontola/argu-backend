# frozen_string_literal: true

class PublishedCreateService < EdgeableCreateService
  private

  def after_save
    super
    return if resource.store_in_redis?
    resource.publisher.follow(resource.edge, :reactions, :news)

    return if resource.parent_model(:forum).nil? || resource.publisher.has_favorite?(resource.parent_model(:forum).edge)
    resource.publisher.favorites.create(edge: resource.parent_model(:forum).edge)
  end
end
