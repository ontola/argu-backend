# frozen_string_literal: true

class ActivityPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      return scope.none if user.nil?

      filter_granted_edges(scope.joins(:trackable))
        .where(edges: {active_branch: true})
    end

    private

    # A grant should be present for the trackable
    def filter_granted_edges(scope)
      return scope if staff?

      scope
        .with(granted_paths)
        .joins(granted_path_type_join(Activity.arel_table))
    end
  end

  permit_attributes %i[comment notify]

  def show?
    edgeable_policy.show?
  end
end
