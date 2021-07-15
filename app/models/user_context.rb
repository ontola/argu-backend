# frozen_string_literal: true

# @private
# Puppet class to help [Pundit](https://github.com/elabs/pundit) grasp our complex {Profile} system.
class UserContext # rubocop:disable Metrics/ClassLength
  include JWTHelper

  attr_accessor :doorkeeper_token
  attr_reader :allow_expired

  delegate :user, :profile, to: :current_actor
  delegate :guest?, :id, :language, :otp_active?, to: :user

  def initialize(allow_expired: false, doorkeeper_token: nil, language: nil, profile: nil, user: nil, session_id: nil) # rubocop:disable Metrics/ParameterLists
    @allow_expired = allow_expired
    @doorkeeper_token = doorkeeper_token
    @session_id = session_id
    @profile = profile
    @user = user
    @language = language
    @lookup_map = {}
    @grant_trees = {}
  end

  def current_actor
    @current_actor ||= authorized_current_actor(@user || user_from_token, @profile)
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

  def doorkeeper_token_payload # rubocop:disable Metrics/AbcSize
    return {} if doorkeeper_token&.token.blank?
    return {} if !allow_expired && !doorkeeper_token.accessible?

    @doorkeeper_token_payload ||= decode_token(doorkeeper_token.token)
  rescue JWT::ExpiredSignature
    return {} unless allow_expired

    decode_token(doorkeeper_token.token, exp_leeway: 1.year.to_i)
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

  def inspect
    "<UserContext user_id: #{user.id}, profile_id: #{profile.id}>"
  end

  def managed_profile_ids
    return [] if user.guest?
    return [user.profile.id, ActsAsTenant.current_tenant.profile.id] if page_manager?

    [user.profile.id]
  end

  def page_manager? # rubocop:disable Metrics/MethodLength
    @page_manager ||=
      PermittedAction
        .joins(grant_sets: {grants: {group: :group_memberships}})
        .where(
          resource_type: 'Page',
          action_name: 'update',
          grants: {edge_id: ActsAsTenant.current_tenant.uuid},
          group_memberships: {member_id: user.profile.id},
          permitted_actions: {resource_type: 'Page', action_name: 'update'}
        )
        .any?
  end

  def profile=(new_profile)
    @current_actor = authorized_current_actor(user, new_profile)
  end

  def service_scope?
    doorkeeper_scopes&.include? 'service'
  end

  def session_id
    @session_id ||= doorkeeper_token_payload['session_id'] || SecureRandom.hex
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

  def user=(new_user)
    @current_actor = authorized_current_actor(new_user, new_user.profile)
  end

  def with_root(root)
    raise 'no root given' if root.nil?

    ActsAsTenant.with_tenant(root) { yield }
  end

  private

  def authorized_current_actor(user, profile)
    user ||= User.guest(session_id)

    if profile
      @current_actor = CurrentActor.new(user: user, profile: profile)

      return @current_actor if CurrentActorPolicy.new(self, current_actor).show?
    end

    @current_actor = CurrentActor.new(user: user, profile: user.profile)
  end

  def user_from_token
    return User.guest(session_id, user_payload['language']) if user_payload['id'].to_s == User::GUEST_ID.to_s

    User.find(user_payload['id']) if user_payload['id']
  end

  def user_payload
    doorkeeper_token_payload['user'] || {}
  end
end
