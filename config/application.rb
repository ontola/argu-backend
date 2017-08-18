# frozen_string_literal: true
require_relative 'boot'

require_relative './initializers/version'
require_relative './initializers/build'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Argu
  class Application < Rails::Application
    config.token_url = ENV['TOKEN_SERVICE_URL']
    config.frontend_url = "https://#{ENV['FRONTEND_HOSTNAME'] || 'beta.argu.co'}"

    config.autoload_paths += %W(#{config.root}/app/models/banners)
    config.autoload_paths += %W(#{config.root}/app/services)
    config.autoload_paths += Dir["#{config.root}/app/services/**/"]
    config.autoload_paths += %W(#{config.root}/app/listeners)
    config.autoload_paths += %W(#{config.root}/app/serializers/base)
    config.autoload_paths += %W(#{config.root}/app/policies/edge_tree_policies)
    config.autoload_paths += %W(#{config.root}/app/policies/edgeable_policies)

    config.paths['app/views'].unshift("#{Rails.root}/lib/app/views")

    config.active_job.queue_adapter = :sidekiq
    ENV['REDIS_URL'] = ENV['REDIS_URL'].presence ||
      "redis://#{ENV['REDIS_ADDRESS'] || 'localhost'}:#{ENV['REDIS_PORT'] || 6379}/12"

    config.app_generators.template_engine :slim

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.cookie_name = '_Argu_sesion'

    config.generators do |g|
      g.test_framework :rspec, fixture: true, views: false
      g.integration_tool :rspec, fixture: true, views: true
    end

    ActiveSupport::Reloader.to_prepare do
      Devise::SessionsController.layout 'closed'
    end

    ActiveModelSerializers.config.key_transform = :camel_lower

    ############################
    # Middlewares
    ############################

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins Rails.configuration.frontend_url
        resource '*',
                 headers: :any,
                 methods: %i(get post put patch delete options)
      end

      allow do
        origins Rails.configuration.host_name, 'argu.co', 'd3hv9pr8szmavn.cloudfront.net'
        resource '/assets/*',
                 headers: :any,
                 methods: %i(get options)
      end

      allow do
        origins '*'
        resource(/\d+.widget/,
                 headers: ['Origin', 'Accept', 'Content-Type'],
                 methods: [:get])
      end
    end
    # config.middleware.use Rack::Attack
    config.middleware.use Rack::Deflater

    ############################
    # Assets
    ############################

    require 'argu/stateful_server_renderer'
    config.react.addons = false
    config.react.server_renderer = StatefulServerRenderer
    # Enable the asset pipeline
    config.assets.enabled = true

    ############################
    # I18n & locales
    ############################

    config.time_zone = 'UTC'
    I18n.available_locales = [:nl, :en]
    config.i18n.available_locales = [:nl, :en]
    config.i18n.load_path += Dir["#{Rails.root}/config/locales/**/*.{rb,yml}"]
    config.i18n.enforce_available_locales = true
    I18n.enforce_available_locales = true
    config.i18n.default_locale = :nl
    I18n.locale = :nl
  end
end
