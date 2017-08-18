# frozen_string_literal: true
# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :doorkeeper_scopes, :opts, :cached_nodes, :tree_root

  class Node
    attr_accessor :id, :expired, :trashed, :unpublished, :children, :user_context
    alias expired? expired
    alias trashed? trashed
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
      n.expired = edge.owner.starts_at > DateTime.current if !n.expired && edge.owner_type == 'VoteEvent'
      n.trashed = parent&.trashed || edge.is_trashed?
      n.unpublished = parent&.unpublished || !edge.is_published
      n.user_context = user_context
      user_context.cached_nodes[n.id] = n
      n
    end

    # Adds a child to this node
    # @param [Edge] edge The child to add
    # @return [Edge] The child that was added
    def add_child(edge)
      raise 'Inconsistent node' unless edge.parent_id == id
      Node.build(edge, self, user_context)
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

  def has_tree?
    @tree_root.present?
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
    return unless tree.present?
    @cached_nodes = {}
    root = tree.find { |e| e.parent_id.blank? }
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
