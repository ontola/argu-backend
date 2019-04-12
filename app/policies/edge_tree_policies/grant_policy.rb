# frozen_string_literal: true

class GrantPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[grant_set_id _destroy id]
    attributes.concat %i[group_id] if record.persisted? || record.group.blank?
    attributes.concat %i[edge_id] if record.persisted? || record.edge.blank?
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
