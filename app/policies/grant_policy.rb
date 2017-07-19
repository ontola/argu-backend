# frozen_string_literal: true
class GrantPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i(group_id edge_id role)
    attributes
  end

  private

  def create_roles
    [is_super_admin?, super]
  end

  def destroy_roles
    return [] if record.group_id == Group::PUBLIC_ID || record.super_admin?
    [is_super_admin?, super]
  end
end
