# frozen_string_literal: true
class GroupPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      # Don't show closed, unless the user has a membership
      scope.where('visibility IN (?) OR groups.id IN (?)',
                  [Group.visibilities[:open], Group.visibilities[:discussion]],
                  user.profile.group_memberships.pluck(:group_id))
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(name name_singular icon visibility) if create?
    attributes.append :id if staff?
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(members invite general grants advanced) if is_super_admin? || staff?
    tabs
  end

  def settings?
    update?
  end

  def is_member?
    member if user&.profile&.group_memberships&.pluck(:group_id)&.include? record.id
  end

  private

  def create_roles
    [is_super_admin?, super]
  end

  def default_tab
    'members'
  end

  def destroy_roles
    return [] unless record.deletable
    [is_super_admin?, super]
  end

  def update_roles
    [is_super_admin?, super]
  end

  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles
end
