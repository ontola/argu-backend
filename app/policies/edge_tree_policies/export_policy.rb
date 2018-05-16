# frozen_string_literal: true

class ExportPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    administrator? || staff?
  end

  def destroy?
    administrator? || staff?
  end

  def show?
    administrator? || staff?
  end
end
