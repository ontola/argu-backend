# frozen_string_literal: true
class EdgeTreePolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    def class_name
      self.class.name.split('Policy')[0]
    end

    def resolve
      return scope.published.untrashed if staff?
      scope
        .joins(:edge)
        .where("edges.path ? #{Edge.path_array(granted_edges_within_tree || user.profile.granted_edges)}")
        .published
        .untrashed
    end

    def granted_edges_within_tree
      return unless context.has_tree?
      user.profile.granted_edges.where('path <@ ?', context.tree_root.id.to_s)
    end
  end

  delegate :has_expired_ancestors?, :has_trashed_ancestors?, :has_unpublished_ancestors?, to: :edgeable_policy

  def initialize(context, record)
    super
    raise('No edgeable record avaliable in policy') unless edgeable_record
  end

  private

  def edgeable_policy
    @edgeable_policy ||= Pundit.policy(context, edgeable_record)
  end
end
