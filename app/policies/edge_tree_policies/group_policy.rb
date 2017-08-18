# frozen_string_literal: true
class GroupPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def is_member?
    member if user&.profile&.group_memberships&.pluck(:group_id)&.include? record.id
  end

  def edge
    record.parent_edge
  end

  def edgeable_record
    record.parent_model
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(name name_singular) if create?
    attributes.append(grants_attributes: %i(id role edge_id group_id))
    attributes.append :id if staff?
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(members invite general grants advanced) if is_super_admin? || staff?
    tabs
  end

  def show?
    rule is_member?, is_manager?, is_super_admin?, service?, staff?
  end

  def create?
    rule is_super_admin?, super()
  end

  def destroy?
    return false unless record.deletable
    rule is_super_admin?, staff?
  end

  def settings?
    update?
  end

  def update?
    rule is_super_admin?, super
  end

  private

  def default_tab
    'members'
  end
end
