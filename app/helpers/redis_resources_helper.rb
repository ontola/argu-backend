# frozen_string_literal: true

module RedisResourcesHelper
  include NestedResourceHelper

  def schedule_redis_resource_worker(old_user, new_user, redirect = nil)
    resource = LinkedRails.iri_mapper.resource_from_iri(path_to_url(redirect), nil) if redirect.present?
    if resource.is_a?(Edge) && resource.default_vote_event.present?
      ActsAsTenant.with_tenant(resource.root) do
        RedisResource::Relation.where(publisher: old_user, parent: resource.default_vote_event).persist(new_user)
      end
    end
    RedisResourceWorker.perform_async(
      old_user.identifier,
      new_user.identifier
    )
  end
end
