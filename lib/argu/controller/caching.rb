# frozen_string_literal: true

module Argu
  module Controller
    module Caching
      extend ActiveSupport::Concern

      def render_to_body(options = {})
        body_render_cache do
          super
        end
      end

      private

      def body_render_cache_key
        @body_render_cache_key ||= [
          VERSION,
          ActsAsTenant.current_tenant.uuid,
          request.path,
          request.params,
          cache_timestamp,
          request.format.to_s,
          user_cache_key
        ].compact.hash
      end

      def body_render_cache
        return yield unless cache_body_render? && body_render_cache_key
        cache body_render_cache_key do
          body = yield
          raise 'caching empty body' if body.blank?
          body
        end
      end

      def cache_body_render?
        request.method == 'GET' && !request.format.html?
      end

      def user_cache_key
        current_user.identifier if cache_per_user?
      end

      def cache_per_user?
        false
      end

      def cache_timestamp
        @cache_key_timestamp ||= (current_resource || try(:parent_resource)).try(:updated_at)
      end
    end
  end
end
