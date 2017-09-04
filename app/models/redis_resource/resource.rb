# frozen_string_literal: true

module RedisResource
  class Resource
    include ActiveModel::Model
    attr_accessor :resource
    attr_writer :key

    def destroy
      remove_from_redis
    end

    def persist(user)
      if Edge.where(user: user, owner_type: resource.class.name, parent_id: resource.edge.parent_id).any?
        Argu::Redis.delete(key.key)
        return
      end
      service = "Create#{resource.class.name}".constantize.new(
        resource.edge.parent,
        attributes: resource.attributes,
        options: {
          creator: user.profile,
          publisher: user
        }
      )
      service.resource.edge.id = resource.edge.id
      service.on("create_#{resource.class.name.underscore}_failed") do |resource|
        raise StandardError.new(resource.errors.full_messages.join('\n'))
      end
      service.on("create_#{resource.class.name.underscore}_successful") do
        Argu::Redis.delete(key.key)
      end
      service.commit
    end

    def save
      resource.edge.id ||= reserved_edge_id
      resource.id ||= reserved_resource_id
      resource.created_at ||= DateTime.current
      store_in_redis
      resource.persisted? ? resource.save!(skip_redis: true) : resource.run_callbacks(:redis_save)
      DataEvent.publish(resource)
    end

    private

    def key
      @key ||= RedisResource::Key.new(
        user_type: resource.publisher.class.name,
        user_id: resource.publisher.id,
        owner_type: resource.class.name,
        edge_id: resource.edge.id,
        path: resource.edge.parent.path
      )
    end

    def remove_from_redis
      raise ActiveRecord::RecordNotFound unless key.present?
      raise "Cannot destroy a key with wildcards: #{key.key}" if key.has_wildcards?
      Argu::Redis.delete(key.key)
    end

    def reserved_edge_id
      ActiveRecord::Base
        .connection
        .execute("SELECT nextval('edges_id_seq'::regclass)")
        .first['nextval']
    end

    def reserved_resource_id
      resource_seq = ActiveRecord::Base.connection.quote_string("#{resource.class.name.tableize}_id_seq")
      ActiveRecord::Base
        .connection
        .execute("SELECT nextval('#{resource_seq}'::regclass)")
        .first['nextval']
    end

    def store_in_redis
      Argu::Redis.set(key.key, resource.attributes.to_json)
      Argu::Redis.expire(key.key, ttl) if ttl.present?
    end

    def ttl
      3.hours.to_i if resource.publisher.guest?
    end

    class << self
      # @param [String, RedisResource::Key] key The key to look for
      # @param [User] user The user of the record
      # @param [Edge] parent The parent of the record
      # @return [RedisResource::Resource] The found record wrapped in a RedisResource::Persistence
      def find(key, user: nil, parent: nil)
        key = RedisResource::Key.parse(key) if key.is_a?(String)
        attributes = key.attributes
        parent ||= Edge.find(key.parent_id)
        user ||= key.user
        return if attributes.nil?
        klass = ApplicationRecord.descendants.detect { |model| model.name == key.owner_type.classify }
        if attributes['persisted']
          resource = klass.find_by(id: attributes['id'])
          resource.assign_attributes(attributes.except('persisted'))
        else
          resource = Edge.new(
            id: key.edge_id,
            owner: klass.new(attributes),
            parent: parent
          ).owner
        end
        resource.publisher = user
        resource.creator = user.profile
        new(key: key, resource: resource)
      end
    end
  end
end
