# frozen_string_literal: true

class PhasePolicy < EdgePolicy
  def permitted_attribute_names
    super + %i[display_name description time order]
  end

  delegate :show?, to: :parent_policy
  delegate :update?, to: :parent_policy

  def create?
    parent_policy.update?
  end

  def trash?
    parent_policy.update?
  end

  def destroy?
    parent_policy.update?
  end
end
