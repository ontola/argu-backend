# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV['REDIS_URL'].presence || "redis://#{ENV['REDIS_ADDRESS'] || 'localhost'}:#{ENV['REDIS_PORT'] || 6379}/12"
  }
end

module Sidekiq
  module WebHelpers
    def root_path
      "#{ActsAsTenant.current_tenant.iri.path}#{env['SCRIPT_NAME']}/"
    end
  end
end
