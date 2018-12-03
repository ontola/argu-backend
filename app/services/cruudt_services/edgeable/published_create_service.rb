# frozen_string_literal: true

class PublishedCreateService < EdgeableCreateService
  private

  def after_save # rubocop:disable Metrics/AbcSize
    super
    return if resource.store_in_redis?
    resource.publisher.follow(resource, :reactions, :news)

    return if resource.ancestor(:forum).nil? || resource.publisher.has_favorite?(resource.ancestor(:forum))
    resource.publisher.favorites.create(edge: resource.ancestor(:forum))
  end
end
