unless Rails.env.development?
  Sidekiq.logger.formatter = Sidekiq::Logging::Json::Logger.new
end
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'].presence || "redis://#{ENV['REDIS_ADDRESS'] || 'localhost'}:#{ENV['REDIS_PORT'] || 6379}/12" }
end
