# frozen_string_literal: true

# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :doorkeeper_scopes, :cached_nodes, :grants_in_scope, :rules_in_scope, :tree_root

  def initialize(user, profile, doorkeeper_scopes, tree_relation = nil)
    @user = user
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
    @lookup_map = {}
    @tree_root = build_tree(tree_relation&.to_a)
  end

  def cache_key(ident, key, val)
    return val if ident.nil?
    @lookup_map[ident] ||= {}
    @lookup_map[ident][key] = val
    val
  end

  def cache_node(edge)
    return false if cached?(edge)
    e = edge.is_a?(Edge) ? edge : Edge.find(edge)
    find_or_cache_node(e.parent_id).add_child(e) if e.persisted?
  end

  def check_key(ident, key)
    return if ident.nil?
    @lookup_map.dig(ident, key)
  end

  # Checks whether the edge or any of its ancestors is expired
  # @param [Edge] node The node to check
  # @return [Bool] Whether the edge or any of its ancestors is expired
  def expired?(node)
    return true if node.expires_at? && node.expires_at < DateTime.current
    find_or_cache_node(node).expired?
  end

  # Find all groups with a grant of the specified role on this record or any of its ancestors
  # @param [Edge] record The node to check
  # @param [String] role The role to check
  # @return [Array<Integer>] A list of group_ids with a grant of the specified role
  def granted_group_ids(record, role)
    granted_group_ids = find_or_cache_node(record)
                          .grants_in_scope
                          .select { |grant| grant.role_before_type_cast >= Grant.roles[role] }
                          .map(&:group_id)
    user.profile.group_ids & granted_group_ids
  end

  def has_tree?
    @tree_root.present?
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
  # @param [Edge] node The node to check
  # @return [Bool] Whether the edge or any of its ancestors is trashed
  def trashed?(node)
    return true if node.trashed_at && node.trashed_at < DateTime.current
    find_or_cache_node(node).trashed?
  end

  # Checks whether the edge or any of its ancestors is unpublished
  # @param [Edge] node The node to check
  # @return [Bool] Whether the edge or any of its ancestors is unpublished
  def unpublished?(node)
    return true unless node.is_published?
    find_or_cache_node(node).unpublished?
  end

  # @param [Edge] node The node to check
  # @param [Bool] allow_outside_tree Whether to raise on a node outside the current tree or not.
  # @return [Bool] Whether the Edge falls within the current tree
  def within_tree?(edge, allow_outside_tree)
    return false unless has_tree?
    within_tree = @tree_root.id == edge.root_id
    raise "#{edge.owner_type} lies outside the current tree" unless within_tree || allow_outside_tree
    within_tree
  end

  private

  def build_tree(tree)
    return if tree.blank?
    @cached_nodes = {}
    root = tree.find { |e| e.parent_id.blank? }
    @grants_in_scope =
      Grant
        .joins(:edge)
        .includes(:edge)
        .where("edges.path ~ '?.*'", root.id)
        .to_a
    @rules_in_scope =
      Rule
        .joins(:branch)
        .where("edges.path ~ '?.*'", root.id)
        .to_a
    Node.build_from_tree(tree, root, self)
  end

  def cached_node(edge)
    cached_nodes[edge.is_a?(Edge) ? edge.id : edge]
  end

  # Checks whether the edge is in the current tree
  # @param [Edge, Integer] node The edge or an edge_id to check
  def cached?(node)
    cached_nodes[node.is_a?(Edge) ? node.id : node].present?
  end

  def find_or_cache_node(edge)
    cached_node(edge) || cache_node(edge)
  end
end
