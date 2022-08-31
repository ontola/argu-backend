# frozen_string_literal: true

class GrantPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[grant_set_id _destroy group_id edge_id]

  def create?
    edgeable_policy.update?
  end

  def destroy?
    edgeable_policy.has_grant?(:update)
  end

  def show?
    edgeable_policy.update?
  end
end
