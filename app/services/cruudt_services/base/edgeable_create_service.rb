# frozen_string_literal: true

class EdgeableCreateService < CreateService
  # @note Call super when overriding.
  # @param [Edge] parent The parent edge or its id
  def initialize(parent, attributes: {}, options: {})
    @edge = find_edge(parent, options)
    super
    walk_parents
  end

  def resource
    @edge.owner
  end

  protected

  def find_edge(parent, options)
    parent_edge = parent.is_a?(Edge) ? parent : Edge.find(parent)
    @edge = parent_edge.children.new(
      user: options[:publisher],
      owner: resource_klass.new)
  end

  def parent_columns
    %i(forum_id)
  end

  def walk_parents
    @edge.parent.self_and_ancestors.each do |ancestor|
      if parent_columns.include? ancestor.owner_type.foreign_key.to_sym
        resource[ancestor.owner_type.foreign_key] = ancestor.owner_id
      end
    end
  end
end
