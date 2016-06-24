# frozen_string_literal: true

class ContentCreateService < CreateService
  # @note Call super when overriding.
  # @param [Edge] parent The parent edge or its id
  def initialize(parent, attributes: {}, options: {})
    parent_edge = parent.is_a?(Edge) ? parent : Edge.find(parent)
    @edge = parent_edge.children.new(
      user: options[:publisher],
      owner: resource_klass.new)
    super
  end

  def resource
    @edge.owner
  end

  protected

  def assign_forum_from_edge_tree
    edge = @edge.parent
    edge = edge.parent while edge && edge.owner_type != 'Forum'
    resource.forum = edge.owner
  end
end
