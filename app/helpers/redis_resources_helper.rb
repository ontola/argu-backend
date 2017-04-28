# frozen_string_literal: true
module RedisResourcesHelper
  def schedule_redis_resource_worker(old_user, new_user)
    RedisResourceWorker.perform_async(old_user.class, old_user.id, new_user.class, new_user.id)
  end
end
