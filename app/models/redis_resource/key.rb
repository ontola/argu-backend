# frozen_string_literal: true

module RedisResource
  class Key
    attr_accessor :key, :user, :user_identifier, :owner_type, :root_id
    attr_reader :parent, :parent_id

    # Returns the attributes stored in redis for this key
    # @return [Hash] The stored attributes
    def attributes
      return @attributes if @attributes.present?

      raw = Argu::Redis.get(key)
      @attributes = raw && JSON.parse(raw)
    rescue JSON::ParserError
      nil
    end

    # Generate a key based on the options. Fills in '*' for not provided options
    # @option opts [string] user_identifier
    # @option opts [User] user
    # @option opts [String] owner_type
    # @option opts [Uuid] root_id
    # @option opts [Edge] parent
    # @option opts [Integer] parent_id
    def initialize(**opts) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      opts.compact!
      self.user_identifier ||= opts[:user]&.identifier || opts.fetch(:user_identifier, '*')
      self.user = opts[:user] || load_user || nil
      self.root_id ||= opts.fetch(:root_id, '*')
      self.owner_type ||= opts.fetch(:owner_type, '*')
      self.parent ||= opts.fetch(:parent, nil)
      self.parent_id ||= opts.fetch(:parent_id, '*')
      self.key = "temporary.#{user_identifier}.#{root_id}.#{owner_type.underscore}.#{parent_id}"
    end

    def edge
      redis_resource.resource
    end

    # @return [Bool] Whether the key contains wildcards
    def has_wildcards?
      key.include?('*')
    end

    def matched_keys # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      @matched_keys ||=
        if has_wildcards?
          keys = Argu::Redis.keys(key).map { |key| RedisResource::Key.parse(key, user) }.compact
          keys.map(&:root_id).uniq.each do |root_id|
            scoped_keys = keys.select { |k| k.root_id == root_id }
            parent_edges = Edge.where(root_id: root_id, id: scoped_keys.map(&:parent_id))
            scoped_keys.each { |key| key.parent = parent_edges.find { |edge| edge.id == key.parent_id.to_i } }
          end
          keys
        else
          Argu::Redis.exists?(key) ? [self] : []
        end
    end

    def parent=(parent)
      @parent = parent
      @parent_id = parent&.id
    end

    def parent_id=(parent_id)
      @parent = nil if parent_id && parent && parent.id != parent_id
      @parent_id = parent_id
    end

    # @return [ApplicationRecord] The redis resource stored by this key
    def redis_resource
      @redis_resource ||= RedisResource::Resource.find(
        self,
        user: user,
        parent: parent
      )
    end

    private

    def load_user
      User.from_identifier(user_identifier) if user_identifier.present? && user_identifier != '*'
    end

    class << self
      def parse(key, user = nil)
        values = key.split('.')
        key = new(
          **Hash[%i[user_identifier root_id owner_type parent_id].map.with_index { |k, i| [k, values[i + 1]] }]
            .merge(user: user)
        )
        key if key.user.present?
      end
    end
  end
end
