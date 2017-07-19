# frozen_string_literal: true
class PhasePolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope; end

  def permitted_attributes(force = false)
    attributes = super()
    attributes.concat %i(id name description integer end_date end_time finish_phase _destroy) if force || create?
    attributes.concat %i(name description end_date finish_phase) if update?
    attributes
  end

  private

  def create_roles
    [is_manager?, is_super_admin?, super]
  end

  def update_roles
    [is_manager?, is_super_admin?, super]
  end

  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles
end
