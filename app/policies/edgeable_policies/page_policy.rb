# frozen_string_literal: true
class PagePolicy < EdgeablePolicy
  class Scope < Scope
    def resolve
      t = Page.arel_table

      cond = t[:visibility].eq_any([Page.visibilities[:open], Page.visibilities[:closed]])
      cond = cond.or(t[:id].in(user.profile.granted_record_ids('Page')
                                 .concat(user.profile.pages.pluck(:id))))
      scope.where(cond)
    end
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(profile forums groups advanced) if has_grant_set?(%w(administrator staff))
    tabs.concat %i(sources) if has_grant_set?('staff')
    tabs
  end

  def show?
    record.open? || is_group_member?
  end

  def create?
    pages_left?
  end

  private

  def check_action(_a)
    nil
  end

  def cache_action(_a, v)
    v
  end

  def default_tab
    'profile'
  end

  def is_group_member?
    user.profile.group_memberships.joins(:group).where(groups: {page_id: record.id}).present?
  end

  def pages_left?
    return if user.guest?
    user.profile.pages.length < UserPolicy.new(context, user).max_allowed_pages
  end
end
