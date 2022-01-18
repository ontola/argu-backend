# frozen_string_literal: true

class GrantTree # rubocop:disable Metrics/ClassLength
  NODE_ATTRIBUTES = %i[id parent_id path is_published expires_at trashed_at].freeze
  ID_POSITION = 0
  PARENT_ID_POSITION = 1
  PATH_POSITION = 2
  IS_PUBLISHED_POSITION = 3
  EXPIRES_AT_POSITION = 4
  TRASHED_AT_POSITION = 5

  include UUIDHelper

  ANY_ROOT = :any

  attr_reader :cached_nodes, :tree_root

  def initialize(root)
    raise "Edge expected as root, but got: #{root}" unless root.is_a?(Edge)

    @tree_root = root
    @cached_nodes = {}
  end

  def as_json(_opts = {})
    {}
  end

  def cache_node(edge_id) # rubocop:disable Metrics/AbcSize
    return cached_node(edge_id) if cached?(edge_id)

    edge = edge_id.is_a?(Edge) ? edge_id : Edge.find(edge_id)

    ancestor_ids = cached?(edge.parent_id) ? [edge.id] : edge.self_and_ancestor_ids.reject(&method(:cached?))
    branch_attributes = Edge.where(root: tree_root, id: ancestor_ids).pluck(*NODE_ATTRIBUTES)
    branch_attributes.sort_by { |attrs| attrs[PATH_POSITION].count('.') }.each do |attrs|
      cached_nodes[attrs[ID_POSITION]] = build_node(attrs)
    end

    cached_node(edge.id)
  end

  # Checks whether the edge or any of its ancestors is expired
  # @param [Edge] edge The edge to check
  # @return [Bool] Whether the edge or any of its ancestors is expired
  def expired?(edge)
    return true if edge.expired?

    find_or_cache_node(edge).expired?
  end

  def find_or_cache_node(edge)
    cached_node(edge) || cache_node(edge) || raise('Edge not found')
  end

  # Find the ids of all groups with a grant as specified in the filters
  # @param [Edge] edge The edge to check
  # @param [Hash] filters The filters the grants should apply to
  # @return [Array<Integer>] A list of group_ids with a grant
  def granted_group_ids(edge, **filters)
    find_or_cache_node(edge).granted_group_ids(**filters)
  end

  # Find all groups with a grant as specified in the filters
  # @param [Edge] edge The edge to check
  # @param [Hash] filters The filters the grants should apply to
  # @return [ActiveRecord::Relation] All groups with a grant
  def granted_groups(edge, **filters)
    Group.where(id: granted_group_ids(edge, **filters))
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
  def permitted_parent_types(edge, **filters)
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

  def tree_root_id
    tree_root.uuid
  end

  # Checks whether the edge or any of its ancestors is unpublished
  # @param [Edge] edge The edge to check
  # @return [Bool] Whether the edge or any of its ancestors is unpublished
  def unpublished?(edge)
    return true unless edge.is_published?

    find_or_cache_node(edge).unpublished?
  end

  private

  def build_node(attrs)
    return root_node if attrs[PARENT_ID_POSITION].nil?

    parent_node = cached_node(attrs[PARENT_ID_POSITION])
    raise('Parent node not found') if parent_node.blank?

    parent_node.add_child(
      id: attrs[ID_POSITION],
      path: attrs[PATH_POSITION],
      is_published: attrs[IS_PUBLISHED_POSITION],
      expires_at: attrs[EXPIRES_AT_POSITION],
      trashed_at: attrs[TRASHED_AT_POSITION]
    )
  end

  def cached_node(edge)
    raise 'UUID given' if uuid?(edge)

    cached_nodes[edge.is_a?(Edge) ? edge.id : edge]
  end

  # Checks whether the edge is in the current tree
  # @param [Edge, Integer] edge The edge or an edge_id to check
  def cached?(edge)
    cached_nodes.key?(edge.is_a?(Edge) ? edge.id : edge)
  end

  def root_node
    return cached_node(tree_root.id) if cached?(tree_root.id)

    cached_nodes[tree_root.id] = Node.new(
      grant_tree: self,
      **tree_root.slice(%i[expires_at id is_published trashed_at path])
    )
  end
end
