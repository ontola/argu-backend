# frozen_string_literal: true

class GrantTree
  include UUIDHelper

  ANY_ROOT = :any

  attr_reader :cached_nodes

  def initialize(root)
    @tree_root_id = root if uuid?(root)
    @tree_root = root if root.is_a?(Edge)
    raise ArgumentError.new("Edge expected as root, but got: #{root}") unless @tree_root_id || @tree_root
    @cached_nodes = {}
  end

  def as_json(_opts = {})
    {}
  end

  def cache_node(node)
    return cached_node(node) if cached?(node)
    edge = node.is_a?(Edge) ? node : Edge.find_by!(id: node)
    ancestor_ids = edge.path.split('.').map(&:to_i) - cached_nodes.keys - [edge.id]
    ancestors = ancestor_ids.present? ? Edge.where(root: tree_root, id: ancestor_ids) : []
    (ancestors + [edge]).sort_by { |e| e.path.length }.each do |ancestor|
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

  # Find the ids of all groups with a grant as specified in the filters
  # @param [Edge] edge The edge to check
  # @param [Hash] filters The filters the grants should apply to
  # @return [Array<Integer>] A list of group_ids with a grant
  def granted_group_ids(edge, filters = {})
    find_or_cache_node(edge).granted_group_ids(filters)
  end

  # Find all groups with a grant as specified in the filters
  # @param [Edge] edge The edge to check
  # @param [Hash] filters The filters the grants should apply to
  # @return [ActiveRecord::Relation] All groups with a grant
  def granted_groups(edge, filters = {})
    Group.where(id: granted_group_ids(edge, filters))
  end

  # All grants available for the root
  # @return [Array<Grant>] An array of all grants in the edge tree branch
  def grants_in_scope
    @grants_in_scope ||=
      Grant
        .joins(:edge)
        .includes(:edge, :grant_set, :permitted_actions)
        .where(edges: {root_id: tree_root_id})
        .includes(:edge)
        .to_a
  end

  # All grant_resets available for the root
  # @return [Array<GrantReset>] An array of all grant_resets in the edge tree branch
  def grant_resets_in_scope
    @grant_resets_in_scope ||=
      GrantReset
        .joins(:edge)
        .where(edges: {root_id: tree_root_id})
        .includes(:edge)
        .to_a
  end

  def grant_sets(edge, group_ids: [])
    find_or_cache_node(edge).grant_sets
      .slice(*group_ids)
      .values
      .flatten
  end

  # Find the permitted parent_types for the given filters
  # @param [Edge] edge The edge to check
  # @param [Hash] filters The filters the grants should apply to
  # @return [Array<String>] A list of the permitted parent_types
  def permitted_parent_types(edge, filters = {})
    find_or_cache_node(edge)
      .permitted_parent_types(filters)
  end

  # Checks whether the edge or any of its ancestors is trashed
  # @param [Edge] edge The edge to check
  # @return [Bool] Whether the edge or any of its ancestors is trashed
  def trashed?(edge)
    return true if edge.is_trashed?
    find_or_cache_node(edge).trashed?
  end

  def tree_root
    @tree_root ||= Edge.find_by!(uuid: tree_root_id)
  end

  def tree_root_id
    @tree_root_id ||= @tree_root.uuid
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
    raise 'UUID given' if uuid?(edge)
    cached_nodes[edge.is_a?(Edge) ? edge.id : edge]
  end

  # Checks whether the edge is in the current tree
  # @param [Edge, Integer] edge The edge or an edge_id to check
  def cached?(edge)
    cached_node(edge).present?
  end

  def find_or_cache_node(edge)
    cached_node(edge) || cache_node(edge) || raise('Edge not found')
  end

  def root_node(node = nil)
    return cached_node(tree_root.id) if cached?(tree_root.id)
    raise SecurityError.new('Node with different root given') if node.root_id != tree_root_id
    @tree_root ||= node if node.present?
    cached_nodes[tree_root.id] = Node.new(tree_root, nil, self)
  end
end
