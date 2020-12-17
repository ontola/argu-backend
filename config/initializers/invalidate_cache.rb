# frozen_string_literal: true

Argu::Cache.invalidate_all if Rails.env.development? || ENV['INVALIDATE_CACHE_ON_BOOT']
