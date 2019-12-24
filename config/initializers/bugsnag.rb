# frozen_string_literal: true

Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG_KEY']
  config.notify_release_stages = %w[production staging]
  config.app_version = "v#{::VERSION}/#{::BUILD}"
end

Bugsnag.before_notify_callbacks << lambda { |report|
  report.add_tab(
    :tenant,
    schema: Apartment::Tenant.current,
    server: ENV['SERVER_NAME'],
    tenant: ActsAsTenant.current_tenant&.url,
    tenant_id: ActsAsTenant.current_tenant&.uuid
  )
}
