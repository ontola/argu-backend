# frozen_string_literal: true

module RedisResource
  class Relation
    include Enumerable
    include ActiveModel::Model
    attr_accessor :where_clause, :user, :owner_type, :edge_id
    attr_reader :parent, :parent_id
    delegate :count, :empty?, to: :filtered_keys

    # Clears the caches
    def clear
      clear_key
      clear_redis_resources
    end

    def each(&block)
      redis_resources.each(&block)
    end

    # @return [RedisResource::Resource] The first found redis resources based on the current filters
    def first
      filtered_keys.first&.redis_resource
    end

    # Adds filters and returns the first result
    # @return [RedisResource::Resource] The first found redis resources based on the current filters
    def find_by(opts)
      apply_filters(opts)
      first
    end

    def initialize(opts = {})
      self.where_clause = {}
      super
    end

    # Store the resources matching the current filters in postgres
    def persist(user)
      redis_resources.each { |record| record.persist(user) }
    end

    # Adds filters to the current relation
    def where(opts)
      apply_filters(opts)
      self
    end

    private

    def apply_filters(opts)
      clear_key if (opts.keys & %i[publisher creator parent parent_id owner_type edge_id]).any?
      self.user = opts.delete(:publisher) if opts[:publisher].present?
      self.user = opts.delete(:creator)&.profileable if opts[:creator].present?
      %i[parent parent_id owner_type edge_id].each do |attr|
        send("#{attr}=", opts.delete(attr)) if opts[attr].present?
      end
      clear_filtered_keys if opts.present?
      where_clause.merge!(opts)
    end

    def clear_key
      @key = nil
    end

    def clear_filtered_keys
      @filtered_keys = nil
    end

    def clear_redis_resources
      @redis_resources&.clear
    end

    def filtered_keys
      return key.matched_keys if where_clause.blank?
      @filtered_keys ||= key.matched_keys.select do |key|
        resource = key.redis_resource.resource
        where_clause.all? do |k, v|
          if v.is_a?(Hash)
            v.all? { |nk, nv| filter_value(resource.send(k), nk) == nv }
          else
            filter_value(resource, k) == v
          end
        end
      end
    end

    def filter_value(resource, key)
      value = resource.send(key)
      resource.defined_enums[key.to_s].try(:[], value) || value
    end

    def key
      @key ||= RedisResource::Key.new(
        user: user,
        owner_type: owner_type,
        edge_id: edge_id,
        parent: parent,
        parent_id: parent_id
      )
    end

    def parent=(parent)
      @parent = parent
      @parent_id = parent&.id
    end

    def parent_id=(parent_id)
      @parent = nil if parent_id && parent && parent.id != parent_id
      @parent_id = parent_id
    end

    # @return [Hash<String => RedisResource::Resource>] The found redis resources based on the current filters
    def redis_resources
      @redis_resources ||= filtered_keys.map(&:redis_resource)
    end

    class << self
      def where(opts = {})
        new.where(opts)
      end
    end
  end
end
