Sidekiq.logger.formatter = Sidekiq::Logging::Json::Logger.new if Rails.env.development?

Sidekiq.configure_server do |config|
  config.redis = {url: ENV['REDIS_URL']}
end
