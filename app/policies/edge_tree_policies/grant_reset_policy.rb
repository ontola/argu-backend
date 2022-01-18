# frozen_string_literal: true

class GrantResetPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  permit_attributes %i[edge_id resource_type action_name]

  def create?
    staff?
  end

  def destroy?
    staff?
  end

  def show?
    staff?
  end
end
