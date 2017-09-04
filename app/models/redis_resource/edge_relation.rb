# frozen_string_literal: true

module RedisResource
  class EdgeRelation < RedisResource::Relation
    # @return [Edge] The first found Edge based on the current filters
    def first
      filtered_keys.first&.edge
    end

    # @return [Hash<String => Edge>] The found Edge based on the current filters
    def redis_resources
      @redis_resources ||= filtered_keys.map(&:edge)
    end
  end
end
