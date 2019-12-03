# frozen_string_literal: true

class EmploymentPolicy < EdgePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      scope.where(publisher: user)
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[organization_name job_title industry show_organization_name]
    attributes
  end

  def create?
    true
  end

  def show?
    true
  end
end
