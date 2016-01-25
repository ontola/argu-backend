module Publishable
  module Wrappers
    class Facebook < Wrapper
      def initialize(access_token, *args)
        super()
        @_access_token = access_token
        @_client ||= Koala::Facebook::API.new(@_access_token, Rails.application.secrets.facebook_secret)
      end

      def create(text, name, url = nil, uid = 'me')
        @_client.put_wall_post(text, {name: name, link: url}, uid)
      end

      def email
        me && me['email']
      end

      def image_url
        @_client && fetch_picture
      end

      def name
        me && me['name']
      end

      def username
        nil
      end

      def me
        response = cached_response_for('fetch_object/me')
        if response.blank?
          response = @_client.get_object('me')
          cache_response('fetch_object/me', response)
        end
        response
      end

      def fetch_picture
        response = cached_response_for('fetch_picture/me')
        if response.blank?
          response = @_client.get_picture('me')
          cache_response('fetch_picture/me', response)
        end
        response
      end
    end
  end
end
