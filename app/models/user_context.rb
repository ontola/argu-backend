# frozen_string_literal: true

# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  include UUIDHelper

  attr_reader :user, :actor, :doorkeeper_scopes, :tree_root_id

  def initialize(doorkeeper_scopes:, profile: nil, tree_root_id: nil, user: nil)
    unless tree_root_id.nil? || tree_root_id == GrantTree::ANY_ROOT || uuid?(tree_root_id)
      raise "tree_root_id should be an integer or the constant GrantTree::ANY_ROOT, but is #{tree_root_id}"
    end
    @user = user
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
    @tree_root_id = tree_root_id
    @lookup_map = {}
    @grant_trees = {}
  end

  def cache_key(ident, key, val)
    return val if ident.nil?
    @lookup_map[ident] ||= {}
    @lookup_map[ident][key] = val
    val
  end

  def check_key(ident, key)
    return if ident.nil?
    @lookup_map.dig(ident, key)
  end

  def grant_tree
    grant_tree_for_id(tree_root_id)
  end

  def grant_tree_for(edge)
    return unless edge&.persisted_edge&.present?
    raise 'No root is present' if tree_root_id.nil?
    unless [GrantTree::ANY_ROOT, edge.persisted_edge.root_id].include?(tree_root_id)
      raise "#{edge.owner_type} #{edge.owner_id} lies outside the tree of root #{tree_root_id}"
    end
    @grant_trees[edge.persisted_edge.root_id] ||= GrantTree.new(edge.persisted_edge.root)
  end

  def grant_tree_for_id(edge_id)
    return unless edge_id&.present?
    raise 'No root is present' if tree_root_id.nil?
    unless [GrantTree::ANY_ROOT, edge_id].include?(tree_root_id)
      raise "Edge #{edge_id} lies outside the tree of root #{tree_root_id}"
    end
    @grant_trees[edge_id] ||= GrantTree.new(edge_id)
  end

  def export_scope?
    doorkeeper_scopes&.include? 'export'
  end

  def service_scope?
    doorkeeper_scopes&.include? 'service'
  end

  def system_scope?
    service_scope? || export_scope?
  end

  def with_root_id(root_id)
    original_root_id = tree_root_id
    @tree_root_id = root_id
    result = yield
    @tree_root_id = original_root_id
    result
  end
end
