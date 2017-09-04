# frozen_string_literal: true

module RedisResource
  class Key
    attr_accessor :key, :user, :user_type, :user_id, :owner_type, :edge_id, :path, :parent_id, :parent

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
    # @option opts [String] user_type
    # @option opts [Integer, String] user_id
    # @option opts [User] user
    # @option opts [String] owner_type
    # @option opts [Integer, String] edge_id
    # @option opts [String] path
    def initialize(opts = {})
      opts.compact!
      self.user_type ||= opts[:user]&.class&.to_s&.underscore || opts.fetch(:user_type, '*')
      self.user_id ||= opts[:user]&.id || opts.fetch(:user_id, '*')
      self.user =
        opts[:user] ||
        (user_type == 'user' && User.find(user_id)) ||
        (user_type == 'guest_user' && GuestUser.new(id: user_id)) ||
        nil
      self.owner_type ||= opts.fetch(:owner_type, '*')
      self.edge_id ||= opts.fetch(:edge_id, '*')
      self.path ||= opts.fetch(:path, '*')
      self.parent_id = self.path&.split('.')&.last
      self.key = "temporary.#{user_type.underscore}.#{user_id}.#{owner_type.underscore}.#{edge_id}.#{path}"
    end

    def edge
      redis_resource.resource.edge
    end

    # @return [Bool] Whether the key contains wildcards
    def has_wildcards?
      key.include?('*')
    end

    def matched_keys
      @matched_keys ||=
        if has_wildcards?
          keys = Argu::Redis.keys(key).map { |key| RedisResource::Key.parse(key, user) }
          parent_edges = Edge.where(id: keys.map(&:parent_id))
          keys.each { |key| key.parent = parent_edges.find { |edge| edge.id == key.parent_id.to_i } }
        else
          [self]
        end
    end

    # @return [ApplicationRecord] The redis resource stored by this key
    def redis_resource
      @redis_resources ||= RedisResource::Resource.find(
        self,
        user: user,
        parent: parent
      )
    end

    # Change the user_type and user_id in the key and saves
    # Also remove the ttl
    def transfer(user)
      raise 'Cannot transfer a key with wildcards' if has_wildcards?
      Argu::Redis.persist(key)
      new_key = RedisResource::Key.new(
        path: path,
        owner_type: owner_type,
        edge_id: edge_id,
        user: user
      )
      Argu::Redis.rename(key, new_key.key)
    end

    class << self
      def parse(key, user = nil)
        values = key.split('.')
        new(
          Hash[%i[user_type user_id owner_type edge_id].map.with_index { |k, i| [k, values[i + 1]] }]
            .merge(user: user, path: values[5..values.length].join('.'))
        )
      end
    end
  end
end
