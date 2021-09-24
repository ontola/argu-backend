# frozen_string_literal: true

class InvalidateCacheWorker
  include Sidekiq::Worker

  def perform(current_version, opts = {})
    current_cache_version = Argu::Redis.get('argu.cache.version') || '0'

    return if current_version.is_a?(String) && current_cache_version >= current_version

    Argu::Cache.invalidate_all

    return unless current_version.is_a?(String)

    Page.reindex_with_tenant unless opts[:reindex_search]
    Argu::Redis.set('argu.cache.version', current_version)
  end
end
