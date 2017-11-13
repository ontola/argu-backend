# frozen_string_literal: true

class GrantPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i[group_id edge_id role]
    attributes
  end

  def create?
    edgeable_policy.update?
  end

  def destroy?
    return if record.group_id == Group::PUBLIC_ID || record.super_admin?
    edgeable_policy.update?
  end

  def show?
    edgeable_policy.update?
  end

  private

  def edgeable_record
    @edgeable_record ||= record.page
  end
end
