# include Rails.application.routes.url_helpers

module Publishable
  module Publishers
    class Facebook < Publisher
      def self.publish(identity, publishable)
        client = identity.client
        id = client.create(description, publishable.title, url_for(publishable), identity.uid)
        Sidekiq::Logging.logger.info "FACEBOOK post_id: #{id}"
      end
    end
  end
end
