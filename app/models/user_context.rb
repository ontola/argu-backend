# frozen_string_literal: true

# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_accessor :user
  attr_reader :actor, :doorkeeper_scopes

  def initialize(doorkeeper_scopes:, profile: nil, user: nil)
    @user = user || GuestUser.new
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
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
    grant_tree_for(tree_root)
  end

  def grant_tree_for(edge) # rubocop:disable Metrics/AbcSize
    return unless edge&.persisted_edge&.present?
    raise 'No root is present' if tree_root.nil?
    unless edge.persisted_edge.root_id == tree_root.uuid
      raise "#{edge.owner_type} #{edge.owner_id} lies outside the tree of root #{tree_root.url}"
    end

    @grant_trees[tree_root.uuid] ||= GrantTree.new(tree_root)
  end

  def cache_scope?
    doorkeeper_scopes&.include? 'cache'
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

  def tree_root
    ActsAsTenant.current_tenant
  end

  def tree_root_id
    tree_root&.uuid
  end

  def with_root(root)
    raise 'no root given' if root.nil?

    ActsAsTenant.with_tenant(root) { yield }
  end
end
