#include Rails.application.routes.url_helpers

module Publishable
  module Publishers
    class Twitter < Publisher
      def self.publish(identity, publishable)
        client = identity.client
        id = client.create("#{publishable.tweet_message} #{url_for(publishable)}")
        Sidekiq::Logging.logger.info "TWITTER post_id: #{id}"
      end
    end
  end
end
