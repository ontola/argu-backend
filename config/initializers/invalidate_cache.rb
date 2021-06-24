# frozen_string_literal: true

InvalidateCacheWorker.perform_async(-1, false) if Rails.env.development? || ENV['INVALIDATE_CACHE_ON_BOOT']
