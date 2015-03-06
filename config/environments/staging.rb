Argu::Application.configure do
  config.host = ENV['HOSTNAME'] || 'argu.co'
  # Settings specified here will take precedence over those in config/application.rb

  config.epics = ActiveSupport::OrderedOptions.new
  config.epics.opinion = true                         # Opinion enabled?
  config.epics.parties = true                         # Parties enabled?
  config.epics.advanced_navigation = false            # Navigation by tags and such
  config.epics.search = false                         # Search enabled?
  config.epics.counters = false                       # Counter caches on models (e.g. x pro, y con args)
  config.epics.forum_selector = true                  # Show forum selector in nav bar?
  config.epics.sign_up = false                        # Can users sign up outside of invitations
  config.epics.activities = true                      # Can users see the activity index / timeline button in header?
  config.epics.share_links = true                     # Can first-time users visit forum urls, and can members share them?
  config.epics.open_auth = true                       # Facebook, twitter, google, openID login & account linking shown in profile
  config.epics.link_to_motion = true                  # Button in questions.show to find & link motions
  config.epics.page_create = true                     # Create a page button in header menu
  config.epics.notifications = true                   # Show notifications button in header menu
  config.epics.motions_in_question_partial = false     # Show motions in question partial


  config.logstasher.enabled = true
  config.logstasher.log_controller_parameters = true

  config.react.variant = :production

  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
  
  # See everything in the log (default is :info)
  config.log_level = ENV['LOG_LEVEL'] || :info

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  config.session_store :cookie_store, key: '_Argu_session', domain: (ENV['HOSTNAME'] || 'argu.co')

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, pica_pica.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( closed.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { :host => ENV['HOSTNAME'] || 'argu.co' }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address:              'smtp.gmail.com',
      port:                 587,
      domain:               'argu.nl',
      user_name:            'info@argu.nl',
      password:             ENV['ARGU_GMAIL_PASS'] || Rails.application.secrets.argu_gmail_pass,
      authentication:       'plain',
      enable_starttls_auto: true  }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.active_record.raise_in_transactional_callbacks = true

  config.i18n.available_locales = [:nl, :en]
end
