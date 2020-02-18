# frozen_string_literal: true

require_relative 'boot'

require_relative './initializers/version'
require_relative './initializers/build'

require_relative '../lib/tenant_finder'
require_relative '../lib/tenant_middleware'
require 'rails/all'
require 'linked_rails/middleware/linked_data_params'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/ns'
require_relative '../app/adapters/hex_adapter'
require_relative '../lib/acts_as_tenant/sidekiq_with_tenant'
require_relative '../lib/react-rails/lib/server_rendering/webpack_manifest_container'

module Argu
  class Application < Rails::Application
    config.frontend_url = "https://#{ENV['FRONTEND_HOSTNAME'] || "app.#{ENV['HOSTNAME']}"}"
    config.host_name = ENV['HOSTNAME']
    config.origin = "https://#{Rails.application.config.host_name}"

    OmniAuth.config.full_host = lambda { |_env|
      RequestStore.store[:old_frontend] ? Rails.application.config.origin : Rails.application.config.frontend_url
    }

    config.autoload_paths += %w[lib]
    %i[controllers forms models policies serializers].each do |type|
      config.autoload_paths += %W[#{config.root}/app/#{type}/container_nodes]
    end
    [:controllers, :forms, :models, 'models/menus', :policies, :serializers].each do |type|
      config.autoload_paths += %W[#{config.root}/app/#{type}/rivm]
    end
    config.autoload_paths += %W[#{config.root}/app/models/menus]
    config.autoload_paths += %W[#{config.root}/app/models/menus/container_nodes]
    config.autoload_paths += %W[#{config.root}/app/adapters]
    config.autoload_paths += %W[#{config.root}/app/responders]
    config.autoload_paths += %W[#{config.root}/app/services]
    config.autoload_paths += Dir["#{config.root}/app/services/**/"]
    config.autoload_paths += %W[#{config.root}/app/listeners]
    config.autoload_paths += %W[#{config.root}/app/serializers/base]
    config.autoload_paths += Dir["#{config.root}/app/policies/**/"]
    config.autoload_paths += Dir["#{config.root}/app/enhancements/**/"]
    Dir.glob("#{config.root}/app/enhancements/**{,/*/**}/*.rb").each { |file| require_dependency file }

    config.paths['app/views'].unshift(Rails.root.join('lib', 'app', 'views'))

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

    ActiveModelSerializers.config.key_transform = :camel_lower

    ActiveJob::Base.queue_adapter = :sidekiq

    VideoInfo.provider_api_keys = {youtube: ENV['YOUTUBE_KEY'], vimeo: ENV['VIMEO_KEY']}

    Searchkick.redis = Redis.new
    config.disable_searchkick = ENV['DISABLE_SEARCHKICK'] == 'true'

    ############################
    # Middlewares
    ############################

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins Rails.configuration.host_name, 'argu.co', 'd3hv9pr8szmavn.cloudfront.net'
        resource '/assets/*',
                 headers: :any,
                 methods: %i[get options]
      end

      allow do
        origins '*'
        resource(/\d+.widget/,
                 headers: %w[Origin Accept Content-Type],
                 methods: [:get])
      end
    end
    # config.middleware.use Rack::Attack
    config.middleware.use Rack::Deflater
    config.middleware.use TenantMiddleware
    config.middleware.use LinkedRails::Middleware::LinkedDataParams

    ############################
    # Assets
    ############################

    require 'argu/stateful_server_renderer'
    config.react.addons = false
    config.react.server_renderer = Argu::StatefulServerRenderer
    # Enable the asset pipeline
    config.assets.enabled = true

    ############################
    # I18n & locales
    ############################

    config.time_zone = 'UTC'
    I18n.available_locales = %i[nl en]
    config.i18n.available_locales = %i[nl en]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.enforce_available_locales = true
    I18n.enforce_available_locales = true
    config.i18n.default_locale = ENV['DEFAULT_LOCALE'] || :nl
    I18n.locale = :nl
  end
end
