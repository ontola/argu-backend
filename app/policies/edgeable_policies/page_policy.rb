# frozen_string_literal: true

class PagePolicy < EdgePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name name url iri_prefix styled_headers]
    attributes.concat %i[primary_container_node_id] if record.container_nodes.any?
    attributes.concat %i[last_accepted] unless record.persisted? && record.last_accepted?
    attributes.append(shortname_attributes: %i[shortname]) if new_record?
    attributes.flatten
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[general profile container_nodes groups shortnames banners]
    tabs.concat %i[custom_menu_items] if staff?
    tabs
  end

  def is_creator?; end

  def show?
    true
  end

  def list?
    true
  end

  def create?
    pages_left? || service?
  end

  def default_tab
    'general'
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

    max = UserPolicy.new(context, user).max_allowed_pages
    return true if user.page_count < max

    forbid_with_message(I18n.t('pages.limit_reached_amount', amount: max))
  end

  def valid_child?(klass)
    return true if klass == Shortname

    super
  end
end
