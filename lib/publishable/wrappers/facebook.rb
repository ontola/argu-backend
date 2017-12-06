# frozen_string_literal: true

module Publishable
  module Wrappers
    class Facebook < Wrapper
      def initialize(access_token, *_args)
        super()
        @_access_token = access_token
        @_client ||= Koala::Facebook::API.new(@_access_token, Rails.application.secrets.facebook_secret)
      end

      def create(text, name, url = nil, uid = 'me')
        @_client.put_wall_post(text, {name: name, link: url}, uid)
      end

      def email
        me(:email) && me(:email)['email']
      end

      def image_url
        @_client && fetch_picture
      end

      def name
        me(:name) && me(:name)['name']
      end

      def username
        nil
      end

      def me(*fields)
        cache_key = "fetch_object/me?fields=#{fields.join(',')}"
        response = cached_response_for(cache_key)
        if response.blank?
          response = @_client.get_object('me', fields: fields)
          cache_response(cache_key, response)
        end
        response
      end

      def fetch_picture
        response = cached_response_for('fetch_picture/me')
        if response.blank?
          response = @_client.get_picture('me', type: :large)
          cache_response('fetch_picture/me', response)
        end
        response
      end
    end
  end
end
