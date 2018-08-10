# frozen_string_literal: true

class GroupPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def is_member?
    user&.profile&.is_group_member?(record.id)
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[name name_singular] if create?
    attributes.append(grants_attributes: %i[id grant_set_id edge_id group_id])
    attributes.append :id if staff?
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[members invite general grants advanced] if edgeable_policy.update?
    tabs
  end
  delegate :update?, :show?, to: :edgeable_policy

  def show?
    is_member? || service? || edgeable_policy.update?
  end

  def create?
    edgeable_policy.update?
  end

  def destroy?
    return false unless record.deletable
    edgeable_policy.update?
  end

  def default_tab
    'members'
  end
end
