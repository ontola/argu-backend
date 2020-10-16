# frozen_string_literal: true

class InvalidateCacheWorker
  include Sidekiq::Worker

  def perform(version)
    current_version = version.split('.')[0..1].join('.')
    current_cache_version = Argu::Redis.get('argu.cache.version')

    return if current_cache_version >= current_version

    Argu::Cache.invalidate_all

    Argu::Redis.set('argu.cache.version', current_cache_version)
  end
end
