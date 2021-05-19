# frozen_string_literal: true

class PagePolicy < EdgePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[display_name name url iri_prefix locale]
  permit_attributes %i[primary_container_node_id], new_record: false
  permit_attributes %i[accepted_terms], has_properties: {last_accepted: false}
  permit_attributes %i[matomo_site_id matomo_host], grant_sets: %i[staff]

  def permitted_tabs
    tabs = []
    tabs.concat %i[general profile container_nodes groups shortnames banners vocabularies]
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

  def index_children?(raw_klass, opts = {})
    return show? if [Intervention, Measure].include?(raw_klass)

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
