# frozen_string_literal: true

# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_accessor :tree_root, :user
  attr_reader :actor, :doorkeeper_scopes, :vnext

  def initialize(doorkeeper_scopes:, profile: nil, tree_root: nil, user: nil, vnext: nil)
    raise "tree_root should be a Page but is #{tree_root}" unless tree_root.nil? || tree_root.is_a?(Page)
    @user = user
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
    @tree_root = tree_root || ActsAsTenant.current_tenant
    @vnext = vnext
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
    grant_tree_for(tree_root)
  end

  def grant_tree_for(edge) # rubocop:disable Metrics/AbcSize
    return unless edge&.persisted_edge&.present?
    raise 'No root is present' if tree_root.nil?
    unless edge.persisted_edge.root_id == tree_root.uuid
      raise "#{edge.owner_type} #{edge.owner_id} lies outside the tree of root #{tree_root.url}"
    end
    @grant_trees[edge.persisted_edge.root_id] ||= GrantTree.new(edge.persisted_edge.root)
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

  def tree_root_id
    tree_root&.uuid
  end

  def with_root(root)
    original_root = tree_root
    @tree_root = root
    result = yield
    @tree_root = original_root
    result
  end
end
