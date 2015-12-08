unless Rails.env.development?
  Sidekiq.logger.formatter = Sidekiq::Logging::Json::Logger.new
end
