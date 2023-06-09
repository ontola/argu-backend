# frozen_string_literal: true

require 'argu/service'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  Rails.application.routes.default_url_options[:host] = config.host_name
  Rails.application.routes.default_url_options[:protocol] = :https
  config.hosts << config.host_name
  config.hosts << ".#{Argu::Service::CLUSTER_URL_BASE}"
  config.hosts << '.localdev'

  BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP'] if ENV['TRUSTED_IP']
  config.web_console.whitelisted_ips = ['192.168.0.0/16', '10.0.1.0/16', '172.17.0.0/16', ENV['TRUSTED_IP']].compact

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true
  config.allow_concurrency = true

  # ActiveRecordQueryTrace.enabled = true

  config.eager_load = true

  # Show full error reports.
  config.consider_all_requests_local = true
  config.force_ssl = false
  config.ssl_options = {
    redirect: {
      exclude: ->(request) { request.path == '/d/health' }
    }
  }

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = {
    host: ENV['HOSTNAME'].presence || 'localhost:3000'
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: '127.0.0.1',
    port: ENV['MAIL_PORT'].presence || 1025
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end
