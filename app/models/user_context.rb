# frozen_string_literal: true

# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_accessor :doorkeeper_token, :user
  attr_reader :actor

  def initialize(doorkeeper_token: nil, profile: nil, user: nil)
    @doorkeeper_token = doorkeeper_token
    @user = user || GuestUser.new
    @actor = profile
    @lookup_map = {}
    @grant_trees = {}
  end

  def cache_key(ident, key, val)
    return val if ident.nil?

    @lookup_map[ident] ||= {}
    @lookup_map[ident][key] = val
    val
  end

  def cache_scope?
    doorkeeper_scopes&.include? 'cache'
  end

  def check_key(ident, key)
    return if ident.nil?

    @lookup_map.dig(ident, key)
  end

  def doorkeeper_scopes
    doorkeeper_token&.scopes
  end

  def doorkeeper_token_payload
    @doorkeeper_token_payload ||= JWT.decode(
      doorkeeper_token.token,
      Doorkeeper::JWT.configuration.secret_key,
      true,
      algorithms: [Doorkeeper::JWT.configuration.encryption_method.to_s.upcase]
    )[0]
  end

  def export_scope?
    doorkeeper_scopes&.include? 'export'
  end

  def grant_tree
    grant_tree_for(tree_root)
  end

  def grant_tree_for(edge) # rubocop:disable Metrics/AbcSize
    return unless edge&.persisted_edge&.present?
    raise 'No root is present' if tree_root.nil?
    unless edge.persisted_edge.root_id == tree_root.uuid
      raise "#{edge.owner_type} #{edge.uuid} lies outside the tree of root #{tree_root.url}"
    end

    @grant_trees[tree_root.uuid] ||= GrantTree.new(tree_root)
  end

  def language
    @language ||= doorkeeper_token_payload['user']['language']
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
