# frozen_string_literal: true

class EdgeTreePolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    def grant_tree
      return unless context.tree_root_id.is_a?(Integer)
      @grant_tree ||= context.grant_tree_for_id(context.tree_root_id)
    end

    def granted_edges_within_tree
      user.profile.granted_edges.where('path <@ ?', grant_tree.tree_root_id.to_s) if grant_tree.present?
    end

    def staff?
      grant_tree.granted_group_ids(grant_tree.tree_root_id, 'staff', group_ids: user.profile.group_ids).any?
    end
  end

  module Roles
    def open
      1
    end

    def spectator
      2
    end

    def participator
      3
    end

    # Not an actual role, but reserved nevertheless
    def group_grant
      5
    end

    def moderator
      7
    end

    def owner
      8
    end

    def administrator
      10
    end

    def is_role?(role)
      return if persisted_edge.nil?
      send(role) if grant_tree.granted_group_ids(persisted_edge, role.to_s, group_ids: user.profile.group_ids).any?
    end

    def is_spectator?
      is_role?(:spectator)
    end

    def is_member?
      is_role?(:participator)
    end

    def is_creator?
      return if record.creator.blank?
      creator if record.creator == actor || user.managed_profile_ids.include?(record.creator.id)
    end

    def is_manager?
      is_role?(:moderator) || is_role?(:administrator)
    end

    def is_super_admin?
      is_role?(:administrator)
    end

    def is_manager_up?
      is_manager? || is_super_admin? || staff?
    end

    def staff?
      is_role?(:staff)
    end
  end
  include Roles
  include ChildOperations
  delegate :has_expired_ancestors?, :has_trashed_ancestors?, :has_unpublished_ancestors?,
           :persisted_edge, to: :edgeable_policy
  attr_reader :grant_tree

  def initialize(context, record)
    super
    raise('No edgeable record avaliable in policy') unless edgeable_record
    @grant_tree = context.grant_tree_for(edgeable_record.edge)
  end

  private

  def edgeable_policy
    @edgeable_policy ||= Pundit.policy(context, edgeable_record)
  end

  def edgeable_record; end
end
