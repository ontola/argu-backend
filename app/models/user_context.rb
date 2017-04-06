# frozen_string_literal: true
# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext
  attr_reader :user, :actor, :doorkeeper_scopes, :opts

  def initialize(user, profile, doorkeeper_scopes, resource = nil, opts = {})
    @user = user
    @actor = profile
    @doorkeeper_scopes = doorkeeper_scopes
    @opts = opts
    @lookup_map = {}

    if resource.is_a?(Edge)
      # Collect all grants per ancestor
      @authenticated_ancestors = resource.ancestor_ids

      @all_granted_groups = Group
        .joins(grants: :edge)
        .where(edges: {id: resource.ancestor_ids})
        .order('groups.name ASC')
    end
  end

  def cache_key(ident, key, val)
    @lookup_map[ident] ||= {}
    @lookup_map[ident][key] = val
    val
  end

  def check_key(ident, key)
    v = @lookup_map.dig(ident, key)
    puts "==========CACHE HIT==== I: #{ident} K: #{key} V: #{v} =================" if v
    v
  end

  def granted_group_ids(record, role)
    return record.granted_group_ids(role) unless record.ancestor_ids & @authenticated_ancestors

    puts '!!!!!!!!!!!!USED CACHED GROUP-GRANTS!!!!!!!!!!!!!!!!!'
    role_groups = @all_granted_groups.select { |group| group.grants.select { |grant| grant.role_before_type_cast >= Grant::roles[role] } }.map(&:id)
    user.profile.group_ids & role_groups
  end
end
