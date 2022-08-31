# frozen_string_literal: true

class ExportPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    return false unless administrator? || staff?
    return forbid_wrong_tier unless feature_enabled?(:exports)

    true
  end

  def destroy?
    administrator? || staff?
  end

  def show?
    administrator? || staff?
  end
end
