# frozen_string_literal: true

class GrantPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[group_id edge_id grant_set_id]
    attributes
  end

  def create?
    edgeable_policy.update?
  end

  def destroy?
    return if record.group_id == Group::PUBLIC_ID || record.administrator?
    edgeable_policy.has_grant?(:update)
  end

  def show?
    edgeable_policy.update?
  end
end
