# frozen_string_literal: true

class PropertyDefinitionPolicy < RestrictivePolicy
  permit_attributes %i[predicate property_type]

  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    parent_policy.update?
  end

  def update?
    parent_policy.update?
  end

  def destroy?
    parent_policy.update?
  end
end
