module Publishable
  module Wrappers
    class Facebook < Wrapper

      def initialize(access_token, *args)
        super()
        @_access_token = access_token
        @_client ||= Koala::Facebook::API.new(@_access_token, Rails.application.secrets.facebook_secret)
      end

      def create(text, headline, url = nil, uid = 'me')
        @_client.put_wall_post(text, {name: headline, link: url}, uid)
      end

      def email
        me && me['email']
      end

      def image_url
        @_client && get_picture
      end

      def name
        me && me['name']
      end

      def username
        nil
      end

      def me
        response = cached_response_for('get_object/me')
        if response.blank?
          response = @_client.get_object('me')
          cache_response('get_object/me', response)
        end
        response
      end

      def get_picture
        response = cached_response_for('get_picture/me')
        if response.blank?
          response = @_client.get_picture('me')
          cache_response('get_picture/me', response)
        end
        response
      end
    end
  end
end
