# frozen_string_literal: true
class GrantPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i(group_id edge_id role)
    attributes
  end

  def create?
    edgeable_policy.has_grant?(:update)
  end

  def destroy?
    return if record.group_id == Group::PUBLIC_ID || record.grant_set.title == 'administrator'
    edgeable_policy.has_grant?(:update)
  end

  private

  def edgeable_record
    record.page
  end
end
