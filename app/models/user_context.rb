# frozen_string_literal: true
# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :authenticated_ancestors, :user, :actor, :doorkeeper_scopes, :opts

  class Node
    attr_accessor :id, :record, :expired, :unpublished, :children

    def initialize
      @children = {}
    end

    def self.build_from_tree(tree)
      root = tree.find { |e| e.parent_id.blank? }
      root_node = build(root)
      tree.delete(root)
      last_node = root_node
      # rubocop:disable Style/For
      for _ in 0..tree.length - 1 do
        last_node = last_node.add(tree.delete_at(tree.find_index { |n| n.parent_id == last_node.id }))
      end
      raise 'Missing node' unless tree.empty?
      root_node
    end

    def self.build(edge)
      n = Node.new
      n.id = edge.id
      n.expired = edge.expires_at && edge.expires_at < DateTime.current
      n.unpublished = !edge.is_published
      n
    end

    def add(edge)
      raise 'Inconsistent node' unless edge.parent_id == id
      c = Node.build(edge)
      c.expired = true if expired
      c.unpublished = true if unpublished
      @children[c.id] = c
    end

    def expired?(path)
      cur = path.shift
      raise 'Out of scope' if cur != id
      return expired if expired
      return false if path.empty?
      n_child = children[path[0]]
      n_child.expired?(path)
    end

    def unpublished?(path)
      cur = path.shift
      raise 'Out of scope' if cur != id
      return unpublished if unpublished
      return false if path.empty?
      n_child = children[path[0]]
      n_child.unpublished?(path)
    end
  end

  def initialize(user, profile, doorkeeper_scopes, tree = nil, opts = {})
    @user = user
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
    @opts = opts
    @lookup_map = {}

    return unless tree.present?
    # Collect all grants per ancestor
    @authenticated_ancestors = tree

    @tree = Node.build_from_tree(tree.to_a)
    # tree.map { |edge| @tree.add(edge) unless edge.id == @tree.id }

    @all_granted_groups = Group
      .joins(grants: :edge)
      .where(edges: {id: tree})
      .order('groups.name ASC')
  end

  def cache_key(ident, key, val)
    @lookup_map[ident] ||= {}
    @lookup_map[ident][key] = val
    val
  end

  def check_key(ident, key)
    @lookup_map.dig(ident, key)
  end

  def granted_group_ids(record, role)
    return record.granted_group_ids(role) unless record.ancestor_ids & @authenticated_ancestors

    role_groups = @all_granted_groups.select do |group|
      group.grants.select { |grant| grant.role_before_type_cast >= Grant.roles[role] }
    end
    user.profile.group_ids & role_groups.map(&:id)
  end

  def in_tree?(node)
    r = node
    r = r.parent while r.parent_id && !@authenticated_ancestors.ids.include?(r.parent_id)

    @authenticated_ancestors.ids.include?(r.parent_id) ? true : false
  end

  def expired?(node)
    @tree.expired?(node.ancestor_ids)
  end

  def unpublished?(node)
    @tree.unpublished?(node.ancestor_ids)
  end
end
