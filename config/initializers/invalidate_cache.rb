# frozen_string_literal: true

if Rails.env.development? || ENV['INVALIDATE_CACHE_ON_BOOT']
  require_relative '../../app/workers/invalidate_cache_worker'

  begin
    InvalidateCacheWorker.perform_async(-1, reindex_search: false)
  rescue Redis::CannotConnectError
    Rails.logger.warn 'Cannot connect to Redis, skipping cache invalidation'
  end
end
