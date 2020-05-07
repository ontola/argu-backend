# frozen_string_literal: true

module RedisResource
  class Resource
    include ActiveModel::Model
    attr_accessor :resource
    attr_writer :key

    def destroy
      remove_from_redis
    end

    def key # rubocop:disable Metrics/AbcSize
      @key ||= RedisResource::Key.new(
        root_id: resource.root_id,
        user_type: resource.publisher.class.name,
        user_id: resource.publisher.id,
        owner_type: resource.class.name,
        edge_id: resource.id,
        parent: resource.parent
      )
    end

    def persist(user) # rubocop:disable Metrics/AbcSize
      if Edge.where(publisher: user, owner_type: resource.class.name, parent_id: resource.parent_id).any?
        Argu::Redis.delete(key.key)
        return
      end
      service = "Create#{resource.class.name}".constantize.new(
        resource.parent,
        attributes: resource.attributes.except('publisher_id', 'creator_id'),
        options: {
          creator: user.profile,
          publisher: user
        }
      )
      service.resource.id = resource.id
      service.on("create_#{resource.class.name.underscore}_failed") do |resource|
        raise StandardError.new(resource.errors.full_messages.join('\n'))
      end
      service.on("create_#{resource.class.name.underscore}_successful") do
        Argu::Redis.delete(key.key)
      end
      service.commit
    end

    def save # rubocop:disable Metrics/AbcSize
      resource.created_at ||= Time.current
      store_in_redis
      resource.parent.save! if resource.parent.new_record?
      resource.persisted? ? resource.save!(skip_redis: true) : resource.run_callbacks(:redis_save)
      true
    end

    private

    def remove_from_redis
      raise ActiveRecord::RecordNotFound if key.blank?
      raise "Cannot destroy a key with wildcards: #{key.key}" if key.has_wildcards?

      Argu::Redis.delete(key.key)
    end

    def store_in_redis
      key_string = key.key
      raise "Trying to store a key with wildcards: #{key_string}" if key_string.include?('*')

      Argu::Redis.set(key_string, resource.attributes.to_json)
      Argu::Redis.expire(key_string, ttl) if ttl.present?
    end

    def ttl
      3.hours.to_i if resource.publisher.guest?
    end

    class << self
      # @param [String, RedisResource::Key] key The key to look for
      # @param [User] user The user of the record
      # @param [Edge] parent The parent of the record
      # @return [RedisResource::Resource] The found record wrapped in a RedisResource::Persistence
      def find(key, user: nil, parent: nil) # rubocop:disable Metrics/AbcSize
        key = RedisResource::Key.parse(key) if key.is_a?(String)
        attributes = key.attributes&.except('publisher_id', 'creator_id')
        return if attributes.nil?

        parent ||= Edge.find_by(root_id: key.root_id, id: key.parent_id)
        user ||= key.user
        resource = Edge.new(
          attributes.merge(
            root_id: key.root_id,
            publisher: user,
            creator: user.profile,
            owner_type: key.owner_type.classify,
            parent: parent
          )
        )
        resource.uuid = attributes['uuid']
        new(key: key, resource: resource)
      end
    end
  end
end
