# frozen_string_literal: true

class EmploymentPolicy < EdgePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      scope.where(publisher: user)
    end
  end

  permit_attributes %i[organization_name job_title industry show_organization_name]
  permit_attributes %i[validated], grant_sets: %i[administrator staff]

  def create?
    true
  end

  def show?
    true
  end
end
