# frozen_string_literal: true
module Publishable
  module Wrappers
    class Twitter < Wrapper
      def initialize(access_token, access_secret)
        super()
        @_access_token = access_token
        @_client ||= ::Twitter::REST::Client.new do |config|
          config.consumer_key        = Rails.application.secrets.twitter_key
          config.consumer_secret     = Rails.application.secrets.twitter_secret
          config.access_token        = access_token
          config.access_token_secret = access_secret
        end
      end

      def create(text)
        @_client.update!(text)
      end

      def image_url
        verify && verify.profile_image_uri.to_s
      end

      delegate :name, to: :verify

      def username
        verify&.screen_name
      end

      def verify
        response = cached_response_for('verify_credentials')
        if response.blank?
          response = @_client.verify_credentials
          cache_response('verify_credentials', response)
        end
        response
      end
    end
  end
end
