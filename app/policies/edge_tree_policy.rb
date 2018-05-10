# frozen_string_literal: true

class EdgeTreePolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    include UUIDHelper

    def grant_tree
      return unless uuid?(context.tree_root_id)
      @grant_tree ||= context.grant_tree_for_id(context.tree_root_id)
    end

    def granted_edges_within_tree
      user.profile.granted_edges.where(root_id: grant_tree.tree_root_id) if grant_tree.present?
    end

    def staff?
      grant_tree
        .grant_sets(grant_tree.tree_root, group_ids: user.profile.group_ids)
        .include?('staff')
    end
  end
  include ChildOperations
  delegate :has_expired_ancestors?, :has_trashed_ancestors?, :has_unpublished_ancestors?,
           :persisted_edge, :spectator?, :participator?, :moderator?, :administrator?, :staff?, to: :edgeable_policy
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
