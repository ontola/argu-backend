# frozen_string_literal: true

class PagePolicy < EdgePolicy
  class Scope < Scope
    def resolve
      page_ids = user.profile.granted_record_ids(owner_type: 'Page')
                   .concat(user.edges.where(owner_type: 'Page').pluck(:id))
      scope
        .property_join(:visibility)
        .where(
          'visibility_filter.value IN (?) OR edges.id IN (?)',
          Page.visibilities[:visible],
          page_ids
        )
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name about last_accepted visibility]
    attributes.append(shortname_attributes: %i[shortname]) if new_record?
    attributes.append(profile_attributes: ProfilePolicy
                                            .new(context, record.try(:profile) || Profile.new)
                                            .permitted_attributes)
    attributes.flatten
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[profile forums groups advanced shortnames]
    tabs
  end

  def is_creator?; end

  def show?
    record.visible? || group_member? || service?
  end

  def list?
    raise(ActiveRecord::RecordNotFound) if record.hidden? && !show?
    true
  end

  def create?
    pages_left? || service?
  end

  def default_tab
    'profile'
  end

  private

  def group_member?
    user.profile.group_memberships.joins(:group).where(groups: {root_id: record.uuid}).present?
  end

  def pages_left?
    return if user.guest?
    user.edges.where(owner_type: 'Page').length < UserPolicy.new(context, user).max_allowed_pages
  end

  def valid_child?(klass)
    return true if klass == Shortname
    super
  end
end
