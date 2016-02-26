Bugsnag.configure do |config|
  config.api_key = 'b65723480764039f0c48b01009935be9'
  config.notify_release_stages = %w(production staging)
  config.app_version = "v#{::VERSION}/#{::BUILD}"
end
