# frozen_string_literal: true
# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :doorkeeper_scopes, :opts, :cached_nodes, :grants_in_scope, :rules_in_scope

  class Node
    attr_accessor :id, :expired, :unpublished, :children, :user_context, :grants_in_scope, :rules_in_scope
    alias expired? expired
    alias unpublished? unpublished

    def self.build_from_tree(tree, root, user_context)
      root_node = build(root, nil, user_context)
      tree.delete(root)
      last_node = root_node
      while (index = tree.find_index { |n| n.parent_id == last_node.id })
        last_node = last_node.add_child(tree.delete_at(index))
      end
      raise 'Missing node' unless tree.empty?
      root_node
    end

    def self.build(edge, parent, user_context)
      n = Node.new
      n.id = edge.id
      n.expired = parent&.expired || edge.expires_at && edge.expires_at < DateTime.current
      n.unpublished = parent&.unpublished || !edge.is_published
      n.user_context = user_context
      n.grants_in_scope = user_context.grants_in_scope.select { |grant| grant.edge.path == edge.path }
      n.rules_in_scope = user_context.rules_in_scope.select { |rule| rule.branch_id == n.id }
      user_context.cached_nodes[n.id] = n
      n
    end

    # Adds a child to this node
    # @param [Edge] edge The child to add
    # @return [Edge] The child that was added
    def add_child(edge)
      raise 'Inconsistent node' unless edge.parent_id == id
      c = Node.build(edge, self, user_context)
      c.grants_in_scope.concat(grants_in_scope)
      c.rules_in_scope.concat(rules_in_scope)
      c
    end
  end

  def initialize(user, profile, doorkeeper_scopes, tree_relation = nil, opts = {})
    @user = user
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
    @opts = opts
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

  # Checks whether the edge or any of its ancestors is unpublished
  # @param [Edge] node The node to check
  # @return [Bool] Whether the edge or any of its ancestors is unpublished
  def unpublished?(node)
    return true unless node.is_published?
    find_or_cache_node(node).unpublished?
  end

  # @param [Edge] node The node to check
  # @return [Bool] Whether the Edge falls within the current tree
  def within_tree?(edge)
    return false if @tree_root.nil?
    raise "#{edge.owner_type} lies outside the current tree" if @tree_root.id != edge.root_id
    true
  end

  private

  def build_tree(tree)
    return unless tree.present?
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
