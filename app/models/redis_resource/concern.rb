# frozen_string_literal: true

module RedisResource
  module Concern
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :redis_save, only: :before
    end

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

    def searchable_should_index?
      super && !store_in_redis?
    end

    def store_in_redis?(opts = {})
      self.class.store_in_redis?(attributes.merge(creator: creator).merge(opts))
    end

    def trash
      return super unless store_in_redis?

      destroy
    end

    private

    def remove_from_redis
      RedisResource::Resource.new(resource: self).destroy
    end

    def store_in_redis
      RedisResource::Resource.new(resource: self).save
    end

    class_methods do
      # Selects either persisted or transient record, based on the attributes.
      # @param [Hash] attributes Filter options for the owners of the edge akin to activerecords' `where`.
      # @see #store_in_redis?(attributes).
      # @return [ActiveRecord::Relation, RedisResource::Relation]
      def where_with_redis(attributes = {})
        if store_in_redis?(attributes)
          RedisResource::EdgeRelation.where(attributes.merge(owner_type: name))
        else
          where(attributes)
        end
      end

      def store_in_redis?(opts = {})
        !opts[:skip_redis] && opts[:creator]&.profileable&.guest?
      end
    end
  end
end
