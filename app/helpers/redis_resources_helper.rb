# frozen_string_literal: true

module RedisResourcesHelper
  include IRIHelper

  def schedule_redis_resource_worker(old_user, new_user, redirect = nil)
    resource = resource_from_iri(redirect)
    if resource.is_a?(Edge) && resource.default_vote_event.present?
      RedisResource::Relation.where(publisher: old_user, parent: resource.default_vote_event).persist(new_user)
    end
    RedisResourceWorker.perform_async(old_user.class, old_user.id, new_user.class, new_user.id)
  end
end
