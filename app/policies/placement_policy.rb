# frozen_string_literal: true

class PlacementPolicy < RestrictivePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      scope
        .joins('INNER JOIN edges AS parents_edges ON parents_edges.id = edges.parent_id')
        .where('edges.id IS NULL OR (edges.is_published = true AND edges.trashed_at IS NULL)')
        .where(edges: {root_id: grant_tree.tree_root_id})
        .with(granted_paths)
        .where(granted_path_type_filter)
    end
  end

  permit_attributes %i[coordinates lat lon placement_type zoom_level]

  def show?
    return unless record.placeable_type == 'Edge'

    placeable_policy.show?
  end

  private

  def placeable_policy
    @placeable_policy ||= Pundit.policy(context, record.placeable)
  end
end
