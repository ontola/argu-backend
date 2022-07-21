# frozen_string_literal: true

require_relative 'boot'

require_relative './initializers/version'
require_relative './initializers/build'

require_relative '../lib/tenant_finder'
require_relative '../lib/argu/redis'
require_relative '../lib/argu/i18n_error_handler'
require 'rails/all'
require 'linked_rails/middleware/linked_data_params'
require 'linked_rails/middleware/error_handling'
require 'linked_rails/constraints/whitelist'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'json/ld/api'
require 'json/ld/context'
require 'json/ld/reader'
require 'json/ld/writer'
require_relative '../lib/tenant_middleware'
require_relative '../lib/ns'
require_relative '../lib/acts_as_tenant/sidekiq_with_tenant'
require_relative '../lib/head_middleware'

module Argu
  class Application < Rails::Application
    config.api_only = true

    config.service_name = 'argu'
    config.host_name = ENV['HOSTNAME']
    config.origin = "https://#{Rails.application.config.host_name}"
    config.aws_url = "https://#{ENV['AWS_BUCKET'] || 'argu-logos'}.s3.amazonaws.com"
    config.jwt_encryption_method = :hs512
    config.action_controller.default_protect_from_forgery = true

    config.autoloader = :zeitwerk
    config.autoload_paths += %w[lib lib/input_fields]
    %i[controllers forms menus models policies serializers].each do |type|
      config.autoload_paths << "app/#{type}/container_nodes"
      config.autoload_paths << "app/#{type}/edges"
      config.autoload_paths << "app/#{type}/virtual"
    end
    config.autoload_paths << 'app/policies/edge_tree_policies'
    config.autoload_paths += Dir["#{config.root}/app/services/cruudt_services/**/"]

    config.active_job.queue_adapter = :sidekiq
    ENV['REDIS_URL'] = ENV['REDIS_URL'].presence ||
      "redis://#{ENV['REDIS_ADDRESS'] || 'localhost'}:#{ENV['REDIS_PORT'] || 6379}/12"

    config.cache_stream = ENV['CACHE_STREAM'].presence || 'transactions'
    config.stream_redis_database = (ENV['STREAM_REDIS_DATABASE'])&.to_i || 7

    config.max_file_size = 25_000_000

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.generators do |g|
      g.test_framework :rspec, fixture: true, views: false
      g.integration_tool :rspec, fixture: true, views: true
    end

    config.active_record.yaml_column_permitted_classes = [Symbol]

    ActiveJob::Base.queue_adapter = :sidekiq

    VideoInfo.provider_api_keys = {youtube: ENV['YOUTUBE_KEY'], vimeo: ENV['VIMEO_KEY']}

    Searchkick.redis = Argu::Redis.redis_instance
    config.disable_searchkick = ENV['DISABLE_SEARCHKICK'] == 'true'

    ############################
    # Middlewares
    ############################

    config.middleware.insert_after ActionDispatch::DebugExceptions, LinkedRails::Middleware::ErrorHandling
    config.middleware.insert_after ActionDispatch::DebugExceptions, TenantMiddleware
    # config.middleware.use Rack::Attack
    config.middleware.use Rack::Deflater
    config.middleware.use LinkedRails::Middleware::LinkedDataParams
    config.middleware.use HeadMiddleware

    ############################
    # I18n & locales
    ############################

    config.time_zone = 'UTC'
    I18n.available_locales = %i[de nl en]
    config.i18n.available_locales = %i[de nl en]
    config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.{rb,yml}')]
    config.i18n.enforce_available_locales = true
    I18n.enforce_available_locales = true
    config.i18n.default_locale = ENV['DEFAULT_LOCALE'] || :nl
    I18n.locale = :nl
  end
end
