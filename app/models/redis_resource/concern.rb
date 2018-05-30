# frozen_string_literal: true

module RedisResource
  module Concern
    extend ActiveSupport::Concern

    included do
      def destroy
        remove_from_redis if store_in_redis?
        persisted? ? super : true
      end

      def save(opts = {})
        store_in_redis?(opts) ? store_in_redis : super
      end

      def save!(opts = {})
        store_in_redis?(opts) ? store_in_redis : super
      end

      private

      def remove_from_redis
        RedisResource::Resource.new(resource: self).destroy
      end

      def store_in_redis
        RedisResource::Resource.new(resource: self).save
      end
    end
  end
end
