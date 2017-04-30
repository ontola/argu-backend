# frozen_string_literal: true
class PhasePolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope; end

  def permitted_attributes(force = false)
    attributes = super()
    attributes.concat %i(id name description integer end_date end_time finish_phase _destroy) if force || create?
    attributes.concat %i(name description end_date finish_phase) if update?
    attributes
  end

  def create?
    rule is_moderator?, is_manager?, is_super_admin?, super
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule is_member?, is_moderator?, is_manager?, is_super_admin?, super
  end

  def update?
    rule is_moderator?, is_manager?, is_super_admin?, super
  end
end
