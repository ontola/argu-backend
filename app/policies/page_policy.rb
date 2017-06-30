# frozen_string_literal: true
class PagePolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      t = Page.arel_table

      cond = t[:visibility].eq_any([Page.visibilities[:open], Page.visibilities[:closed]])
      cond = cond.or(t[:id].in(user.profile.granted_record_ids('Page')
                                 .concat(user.profile.pages.pluck(:id))))
      scope.where(cond)
    end
  end

  module Roles
    def is_creator?
      super if persisted_edge
    end

    def is_manager?
      super if persisted_edge
    end

    def is_super_admin?
      super if persisted_edge
    end
  end
  include Roles

  def permitted_attributes
    attributes = super
    if create?
      attributes.concat %i(bio tag_list last_accepted)
      attributes.append(profile_attributes: %i(id name profile_photo))
    end
    if new_record?
      attributes.append :visibility
      attributes.append(shortname_attributes: %i(shortname))
    end
    attributes.append :visibility if is_super_admin? || staff?
    attributes.concat %i(page_id confirmation_string) if change_owner?
    attributes.append(profile_attributes: ProfilePolicy
                                            .new(context,
                                                 record.try(:profile) || Profile)
                                            .permitted_attributes)
    attributes.flatten
  end

  def is_open?
    open if @record.open?
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(profile forums groups advanced) if is_super_admin? || staff?
    tabs.concat %i(sources) if staff?
    tabs
  end

  def show?
    rule is_open?, is_group_member?, is_manager?, super
  end

  def create?
    rule pages_left?, super
  end

  def delete?
    destroy?
  end

  def destroy?
    rule is_manager?, super
  end

  def update?
    rule is_manager?, is_super_admin?, super
  end

  def list?
    rule record.closed?, show?
  end

  def list_members?
    rule is_super_admin?, staff?
  end

  def pages_left?
    return if user.guest?
    member if user.profile.pages.length < UserPolicy.new(context, user).max_allowed_pages
  end

  def statistics?
    false
  end

  private

  def default_tab
    'profile'
  end

  def is_group_member?
    group_grant if user.profile.group_memberships.joins(:group).where(groups: {page: record}).present?
  end
end
