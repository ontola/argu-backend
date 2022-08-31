# frozen_string_literal: true

class GrantResetPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[edge_id resource_type action_name]

  def create?
    return false unless administrator? || staff?
    return forbid_wrong_tier unless feature_enabled?(:grant_resets)

    true
  end

  def destroy?
    return false unless administrator? || staff?
    return forbid_wrong_tier unless feature_enabled?(:grant_resets)

    true
  end

  def show?
    return false unless administrator? || staff?
    return forbid_wrong_tier unless feature_enabled?(:grant_resets)

    true
  end
end
