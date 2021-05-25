# frozen_string_literal: true

class CreateEdge < CreateService
  # @note Call super when overriding.
  # @param [Edge] parent The parent edge or its id
  def initialize(parent, attributes: {}, options: {})
    @edge = initialize_edge(parent, options, attributes)
    super
  end

  def resource
    @edge
  end

  protected

  def after_save
    super

    return if resource.try(:store_in_redis?)

    @edge.publish! if publish_edge?
    notify

    return if resource.is_a?(ContainerNode)

    follow_edge
  end

  # @param [Edge, Integer] parent The instance or id of the parent edge of the new child
  # @option options [Hash] publisher The publisher of the new child
  # @option attributes [Hash] publisher The publisher of the new child
  def initialize_edge(parent, options, attributes)
    parent_edge = parent.is_a?(Edge) ? parent : Edge.find(parent)
    edge = parent_edge.build_child(resource_klass(attributes))
    edge.created_at = attributes.with_indifferent_access[:created_at]
    edge.publisher = options[:publisher]
    edge.creator = options[:creator]
    edge
  end

  def follow_edge
    resource.publisher.follow(resource, :reactions, :news)
  end

  def notify
    conn = ActiveRecord::Base.connection
    conn.execute("NOTIFY edge_created, '#{@edge.id}'")
  end

  def object_attributes=(obj)
    obj.creator ||= resource.creator if obj.respond_to?(:creator)
    obj.publisher ||= resource.publisher if obj.respond_to?(:publisher)
  end

  def publish_edge?
    !(resource_klass.is_publishable? || @attributes[:is_published] == false)
  end

  def resource_klass(attributes = @attributes)
    attributes[:owner_type]&.constantize || super()
  end
end
