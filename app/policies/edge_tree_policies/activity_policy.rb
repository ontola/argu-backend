# frozen_string_literal: true

class ActivityPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      return scope.none if user.nil?

      filter_active_branches(filter_granted_edges(scope))
    end

    private

    # A grant should be present for the trackable
    def filter_granted_edges(scope)
      scope
        .joins(:trackable)
        .with(granted_paths)
        .where(granted_path_type_filter(:activities))
    end

    # Trackable should be in an active branch
    def filter_active_branches(scope)
      scope
        .joins(
          'LEFT JOIN edges AS inactive ON inactive.path @> edges.path AND inactive.id != edges.id AND '\
          'inactive.root_id = edges.root_id AND (inactive.is_published = false OR inactive.trashed_at IS NOT NULL)'
        )
        .where(
          inactive: {id: nil},
          edges: {is_published: true, trashed_at: nil}
        )
    end
  end

  permit_attributes %i[comment notify]

  def show?
    edgeable_policy.show?
  end
end
