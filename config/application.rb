require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'devise'
ROADIE_I_KNOW_ABOUT_VERSION_3 = true


if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  #Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
  Bundler.require(:default, Rails.env)
  require 'sidekiq/middleware/i18n'
end

module Argu
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += %W(#{config.root}/app/services)
    config.autoload_paths += %W(#{config.root}/app/listeners)

    config.paths['app/views'].unshift("#{Rails.root}/lib/app/views")

    config.app_generators.template_engine :slim

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    config.active_record.raise_in_transactional_callbacks = true

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.generators do |g|
      g.test_framework  :rspec, :fixture => true, :views => false
      g.integration_tool :rspec, :fixture => true, :views => true
    end

    config.to_prepare do
      Devise::SessionsController.layout 'closed'
    end

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource %r{\d+.widget},
                 :headers => ['Origin', 'Accept', 'Content-Type'],
                 :methods => [:get]
      end
    end
    config.middleware.use Rack::Attack
    config.middleware.use Rack::Deflater

    require 'argu/stateful_server_renderer'
    config.react.addons = false
    config.react.server_renderer = StatefulServerRenderer
    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.precompile += %w( application.js polyfill.js mail.css )

    config.assets.initialize_on_precompile = true
    config.assets.paths << Rails.root.join('lib', 'assets', 'javascripts')
    config.assets.paths << Rails.root.join('node_modules')

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.time_zone = 'UTC'
    I18n.available_locales = [:nl, :en]
    config.i18n.available_locales = [:nl, :en]
    config.i18n.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.{rb,yml}"]
    config.i18n.enforce_available_locales = true
    I18n.enforce_available_locales = true
    config.i18n.default_locale = :nl
    I18n.locale = :nl
  end

end

