# frozen_string_literal: true

if Rails.env.development? || ENV['INVALIDATE_CACHE_ON_BOOT']
  InvalidateCacheWorker.perform_async(-1, reindex_search: false)
end
