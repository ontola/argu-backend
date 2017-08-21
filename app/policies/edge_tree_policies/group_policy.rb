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

  def permitted_attributes
    attributes = super
    attributes.concat %i(name name_singular) if create?
    attributes.append(grants_attributes: %i(id role edge_id group_id))
    attributes.append :id if staff?
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(members invite general grants advanced) #if is_super_admin? || staff?
    tabs
  end

  def show?
    true
  end

  def create?
    edgeable_policy.has_grant?(:update)
  end

  def destroy?
    return false unless record.deletable
    edgeable_policy.has_grant?(:update)
  end

  def settings?
    update?
  end

  def update?
    edgeable_policy.has_grant?(:update)
  end

  private

  def edgeable_record
    record.parent_model
  end

  def default_tab
    'members'
  end
end
