# frozen_string_literal: true

class PhasePolicy < EdgePolicy
  permit_attributes %i[display_name description time order]
  permit_attributes %i[resource_type], new_record: true

  delegate :show?, to: :parent_policy
  delegate :update?, to: :parent_policy

  def create?
    parent_policy.update?
  end

  def trash?
    return forbid_with_message('actions.phases.destroy.errors.current_phase') if record.current_phase?

    parent_policy.update?
  end

  def destroy?
    return forbid_with_message('actions.phases.destroy.errors.current_phase') if record.current_phase?

    parent_policy.update?
  end
end
