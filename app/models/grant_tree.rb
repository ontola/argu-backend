# frozen_string_literal: true

class GrantTree
  ANY_ROOT = :any

  attr_reader :cached_nodes

  def initialize(root)
    @tree_root_id = root if root.is_a?(Integer)
    @tree_root = root if root.is_a?(Edge)
    raise ArgumentError.new("Edge expected as root, but got: #{root}") unless @tree_root_id || @tree_root
    @cached_nodes = {}
  end

  def cache_node(node)
    return cached_node(node) if cached?(node)
    edge = node.is_a?(Edge) ? node : Edge.find(node)
    ancestors = Edge.find(edge.path.split('.').map(&:to_i) - cached_nodes.keys - [edge.id])
    (ancestors + [edge]).each do |ancestor|
      cached_nodes[ancestor.id] =
        ancestor.parent_id.nil? ? root_node(ancestor) : find_or_cache_node(ancestor.parent_id).add_child(ancestor)
    end
    cached_node(node)
  end

  # Checks whether the edge or any of its ancestors is expired
  # @param [Edge] edge The edge to check
  # @return [Bool] Whether the edge or any of its ancestors is expired
  def expired?(edge)
    return true if edge.expired?
    find_or_cache_node(edge).expired?
  end

  # Find all groups with a grant of the specified role on this edge or any of its ancestors
  # @param [Edge] edge The edge to check
  # @param [String] role The role to check
  # @return [Array<Integer>] A list of group_ids with a grant of the specified role
  def granted_group_ids(edge, role, group_ids: nil)
    granted_group_ids = find_or_cache_node(edge)
                          .grants_in_scope
                          .select { |grant| grant.role_before_type_cast >= Grant.roles[role] }
                          .map(&:group_id)
    if group_ids
      group_ids & granted_group_ids
    else
      granted_group_ids
    end
  end

  def grants_in_scope
    @grants_in_scope ||=
      Grant
        .joins(:edge)
        .includes(:edge)
        .where('edges.path <@ ?', tree_root_id.to_s)
        .to_a
  end

  def rules_in_scope
    @rules_in_scope ||=
      Rule
        .joins(:branch)
        .where('edges.path <@ ?', tree_root_id.to_s)
        .to_a
  end

  # Find all rules active for the action on the record on the edge
  # @param [Edge] edge The position in the edge tree
  # @param [ActiveRecord] record The record to find rules for
  # @param [String] action The action to find rules for
  # @return [Array<Rule>]
  def rules(edge, record, action)
    model_type = record.class.to_s
    model_id = record.try(:id)
    find_or_cache_node(edge.persisted_edge)
      .rules_in_scope
      .select do |rule|
      rule.action == action.to_s && rule.model_type == model_type && [model_id, nil].include?(rule.model_id)
    end
  end

  # Checks whether the edge or any of its ancestors is trashed
  # @param [Edge] edge The edge to check
  # @return [Bool] Whether the edge or any of its ancestors is trashed
  def trashed?(edge)
    return true if edge.is_trashed?
    find_or_cache_node(edge).trashed?
  end

  def tree_root
    @tree_root ||= Edge.find(@tree_root_id)
  end

  def tree_root_id
    @tree_root_id ||= @tree_root.id
  end

  # Checks whether the edge or any of its ancestors is unpublished
  # @param [Edge] edge The edge to check
  # @return [Bool] Whether the edge or any of its ancestors is unpublished
  def unpublished?(edge)
    return true unless edge.is_published?
    find_or_cache_node(edge).unpublished?
  end

  private

  def cached_node(edge)
    cached_nodes[edge.is_a?(Edge) ? edge.id : edge]
  end

  # Checks whether the edge is in the current tree
  # @param [Edge, Integer] edge The edge or an edge_id to check
  def cached?(edge)
    cached_node(edge).present?
  end

  def find_or_cache_node(edge)
    cached_node(edge) || cache_node(edge)
  end

  def root_node(node = nil)
    return cached_node(tree_root_id) if cached?(tree_root_id)
    raise SecurityError.new('Node with different root given') if node.root_id != tree_root_id
    @tree_root ||= node if node.present?
    cached_nodes[tree_root_id] = Node.new(tree_root, nil, self)
  end
end
