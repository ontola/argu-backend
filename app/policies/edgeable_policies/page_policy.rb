# frozen_string_literal: true

class PagePolicy < EdgePolicy
  class Scope < Scope
    def resolve
      page_ids = user.profile.granted_root_ids(nil)
                   .concat(user.page_ids)
      scope
        .property_join(:visibility)
        .where(
          'visibility_filter.value IN (?) OR edges.uuid IN (?)',
          Page.visibilities[:visible],
          page_ids
        )
    end
  end

  def permitted_attribute_names # rubocop:disable Metrics/AbcSize
    attributes = super
    attributes.concat %i[visibility url]
    attributes.concat %i[primary_container_node_id] if record.container_nodes.any?
    attributes.concat %i[display_name about last_accepted] unless record.persisted? && record.last_accepted?
    attributes.append(shortname_attributes: %i[shortname]) if new_record?
    attributes.append(profile_attributes: ProfilePolicy
                                            .new(context, record.try(:profile) || Profile.new(profileable: record))
                                            .permitted_attributes)
    attributes.flatten
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[general profile container_nodes groups shortnames]
    tabs.concat %i[custom_menu_items] if staff?
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

  def index_children?(raw_klass)
    return show? if %i[interventions measures].include?(raw_klass.to_sym)

    super
  end

  private

  def group_member?
    user.profile.group_memberships.joins(:group).where(groups: {root_id: record.uuid}).present?
  end

  # @todo remove if pages are no longer profileable
  def init_grant_tree
    context.with_root(record.root) do
      context.grant_tree_for(record)
    end
  end

  def pages_left?
    return if user.guest?
    user.page_count < UserPolicy.new(context, user).max_allowed_pages
  end

  def valid_child?(klass)
    return true if klass == Shortname
    super
  end
end
