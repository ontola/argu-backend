Argu::Application.configure do
  config.host = ENV['HOSTNAME'] || 'local.host:3000'
  # Settings specified here will take precedence over those in config/application.rb#

  config.epics = ActiveSupport::OrderedOptions.new
  config.epics.opinion = false                        # Opinion enabled?
  config.epics.parties = false                        # Parties enabled?
  config.epics.advanced_navigation = false            # Navigation by tags and such
  config.epics.search = false                         # Search enabled?
  config.epics.counters = true                        # Counter caches on models (e.g. x pro, y con args)
  config.epics.forum_selector = true                  # Show forum selector in nav bar?
  config.epics.sign_up = true                         # Can users sign up outside of invitations
  config.epics.activities = true                      # Can users see the activity index / timeline button in header?
  config.epics.share_links = true                     # Can first-time users visit forum urls, and can members share them?
  config.epics.open_auth = true                       # Facebook, twitter, google, openID login & account linking shown in profile
  config.epics.link_to_motion = true                  # Button in questions.show to find & link motions

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
  config.action_mailer.default_url_options = { :host => ENV['HOSTNAME'] || 'argu.co' }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'argu.nl',
      user_name:            'info@argu.nl',
      password:             Rails.application.secrets.argu_gmail_pass,
      authentication:       'plain',
      enable_starttls_auto: true  }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.active_record.raise_in_transactional_callbacks = true

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.session_store :cookie_store, key: '_Argu_session', domain: :all #, :tld_length => 2

  config.i18n.available_locales = :nl

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
end
