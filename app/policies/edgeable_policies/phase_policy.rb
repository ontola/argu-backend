# frozen_string_literal: true

class PhasePolicy < EdgePolicy
  permit_attributes %i[display_name description time order]

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
