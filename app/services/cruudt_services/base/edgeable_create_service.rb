# frozen_string_literal: true

class EdgeableCreateService < CreateService
  # @note Call super when overriding.
  # @param [Edge] parent The parent edge or its id
  def initialize(parent, attributes: {}, options: {})
    @edge = initialize_edge(parent, options)
    walk_parents
    super
  end

  def resource
    @edge.owner
  end

  protected

  def after_save
    unless resource.store_in_redis?
      @edge.publish! unless resource_klass.is_publishable?
      notify
    end
    super
  end

  # @param [Edge, Integer] parent The instance or id of the parent edge of the new child
  # @option options [User] publisher The publisher of the new child
  def initialize_edge(parent, options)
    parent_edge = parent.is_a?(Edge) ? parent : Edge.find(parent)
    parent_edge.children.new(
      user: options[:publisher],
      owner: resource_klass.new,
      parent: parent_edge
    )
  end

  def notify
    conn = ActiveRecord::Base.connection
    conn.execute("NOTIFY edge_created, '#{@edge.id}'")
  end

  def parent_columns
    %i[forum_id]
  end

  def walk_parents
    @edge.parent.self_and_ancestors.each do |ancestor|
      if parent_columns.include? ancestor.owner_type.foreign_key.to_sym
        resource[ancestor.owner_type.foreign_key] = ancestor.owner_id
      end
    end
  end
end
