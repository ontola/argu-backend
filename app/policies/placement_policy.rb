# frozen_string_literal: true

class PlacementPolicy < RestrictivePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      return scope.none if user.nil?

      filter_granted_edges(scope)
        .where('edges.id IS NULL OR (edges.is_published = true AND edges.trashed_at IS NULL)')
        .where(edges: {root_id: grant_tree.tree_root_id})
    end

    def filter_granted_edges(scope)
      return scope if staff?

      scope
        .joins('INNER JOIN edges AS parents_edges ON parents_edges.id = edges.parent_id')
        .with(granted_paths)
        .joins(granted_path_type_join)
    end
  end

  permit_attributes %i[coordinates lat lon zoom_level]

  delegate :show?, to: :placeable_policy

  private

  def placeable_policy
    @placeable_policy ||= Pundit.policy(context, record.edge)
  end
end
