# frozen_string_literal: true

class EdgeableCreateService < CreateService
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
    unless resource.store_in_redis?
      @edge.publish! unless resource_klass.is_publishable? || @attributes[:is_published] == false
      notify
    end
    super
  end

  # @param [Edge, Integer] parent The instance or id of the parent edge of the new child
  # @option options [Hash] publisher The publisher of the new child
  # @option attributes [Hash] publisher The publisher of the new child
  def initialize_edge(parent, options, attributes)
    parent_edge = parent.is_a?(Edge) ? parent : Edge.find(parent)
    resource_klass(attributes).new(
      created_at: attributes.with_indifferent_access[:created_at],
      publisher: options[:publisher],
      creator: options[:creator],
      parent: parent_edge
    )
  end

  def notify
    conn = ActiveRecord::Base.connection
    conn.execute("NOTIFY edge_created, '#{@edge.id}'")
  end

  def resource_klass(attributes = @attributes)
    attributes[:owner_type]&.constantize || super()
  end
end
