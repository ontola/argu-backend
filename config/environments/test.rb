Rails.application.configure do
  config.host = ENV['HOSTNAME'] || 'www.example.com'
  Rails.application.routes.default_url_options[:host] = 'argu.co'
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=3600'

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Generate digests for assets URLs
  config.assets.digest = true

  config.log_level = ENV['LOG_LEVEL'] || :fatal

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  config.session_store :cookie_store, key: '_Argu_session', domain: :all
  #config.session_store :active_record_store, key: '_Argu_session', domain: 'logos.argu.nl'

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.active_record.raise_in_transactional_callbacks = true

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.active_support.test_order = :random

  config.i18n.available_locales = [:en, :nl]
  config.i18n.default_locale= :en

  OmniAuth.config.test_mode = true
end
