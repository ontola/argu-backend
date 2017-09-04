# frozen_string_literal: true

module Publishable
  module Wrappers
    class Wrapper
      def initialize
        @_request_cache = {}
      end

      def cached_response_for(api_method)
        cache_item = @_request_cache[api_method]
        return nil unless cache_item.present? && cache_item[:secret] == @_access_token
        cache_item[:response]
      end

      def cache_response(api_method, response)
        @_request_cache[api_method] = {access_token: @_access_token, response: response}
      end
    end

    Dir[File.join(File.dirname(__FILE__), '/wrappers/*.rb')].each { |f| require f }
  end
end
