Argu::Application.configure do
  config.host = ENV['HOSTNAME'] || 'local.host:3000'
  # Settings specified here will take precedence over those in config/application.rb#

  config.epics = ActiveSupport::OrderedOptions.new
  config.epics.opinion_buttons = true
  config.epics.opinion = false
  config.epics.parties = false

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.web_console.automount = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => ENV['HOSTNAME'] }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.session_store :cookie_store, key: '_Argu_session', domain: :all, :tld_length => 2

  config.i18n.available_locales = :nl

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
end
