# frozen_string_literal: true

# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  include UUIDHelper

  attr_accessor :tree_root_id
  attr_reader :user, :actor, :doorkeeper_scopes

  def initialize(doorkeeper_scopes:, profile: nil, tree_root_id: nil, user: nil)
    raise "tree_root_id should be a uuid but is #{tree_root_id}" unless tree_root_id.nil? || uuid?(tree_root_id)
    @user = user
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
    @tree_root_id = tree_root_id
    @lookup_map = {}
    @grant_trees = {}
  end

  def afe_request?
    doorkeeper_scopes.include?('afe')
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
    unless edge.persisted_edge.root_id == tree_root_id
      raise "#{edge.owner_type} #{edge.owner_id} lies outside the tree of root #{tree_root_id}"
    end
    @grant_trees[edge.persisted_edge.root_id] ||= GrantTree.new(edge.persisted_edge.root)
  end

  def grant_tree_for_id(edge_id)
    return unless edge_id&.present?
    raise 'No root is present' if tree_root_id.nil?
    raise "Edge #{edge_id} lies outside the tree of root #{tree_root_id}" unless edge_id == tree_root_id
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
