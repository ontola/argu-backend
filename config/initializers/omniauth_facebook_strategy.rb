# frozen_string_literal: true

require 'redis_session'

module OmniAuth
  module Strategies
    class Facebook < OmniAuth::Strategies::OAuth2
      def session
        redis_session || super
      end

      private

      def authorization_token
        @authorization_token ||= env['HTTP_AUTHORIZATION'].try(:[], 7..-1)
      end

      def redis_session
        @redis_session ||= RedisSession.new(authorization_token) if authorization_token
      end
    end
  end
end
