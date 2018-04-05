# frozen_string_literal: true

class PagePolicy < EdgeablePolicy
  class Scope < Scope
    def resolve
      t = Page.arel_table

      cond = t[:visibility].eq_any([Page.visibilities[:open], Page.visibilities[:closed]])
      cond = cond.or(t[:id].in(user.profile.granted_record_ids(owner_type: 'Page')
                                 .concat(user.profile.pages.pluck(:id))))
      scope.where(cond)
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[bio last_accepted visibility confirmation_string]
    attributes.append(shortname_attributes: %i[shortname]) if new_record?
    attributes.append(profile_attributes: ProfilePolicy
                                            .new(context, record.try(:profile) || Profile)
                                            .permitted_attributes)
    attributes.flatten
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[profile forums groups advanced]
    tabs
  end

  def is_creator?; end

  def show?
    record.open? || group_member? || service?
  end

  def list?
    raise(ActiveRecord::RecordNotFound) if record.hidden?
    true
  end

  def create?
    pages_left?
  end

  def default_tab
    'profile'
  end

  private

  def group_member?
    user.profile.group_memberships.joins(:group).where(groups: {page_id: record.id}).present?
  end

  def pages_left?
    return if user.guest?
    user.profile.pages.length < UserPolicy.new(context, user).max_allowed_pages
  end
end
