# frozen_string_literal: true

class ActivityPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      return scope.none if user.nil?

      filter_granted_edges(scope).where(edges: {active_branch: true})
    end

    private

    # A grant should be present for the trackable
    def filter_granted_edges(scope)
      scope
        .joins(:trackable)
        .with(granted_paths)
        .where(granted_path_type_filter(:activities))
    end
  end

  permit_attributes %i[comment notify]

  def show?
    edgeable_policy.show?
  end
end
