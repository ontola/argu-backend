# frozen_string_literal: true

class PagePolicy < EdgePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[display_name name url iri_prefix locale]
  permit_attributes %i[primary_container_node_id delete], new_record: false
  permit_attributes %i[confirmation_text], new_record: true
  permit_attributes %i[requires_intro matomo_site_id matomo_host piwik_pro_site_id piwik_pro_host google_tag_manager
                       google_uac],
                    grant_sets: %i[staff],
                    new_record: false

  def permitted_tabs
    tabs = []
    tabs.concat %i[general profile container_nodes groups shortnames banners vocabularies delete] if update?
    tabs.concat %i[custom_menu_items] if staff?
    tabs
  end

  def public_resource?
    true
  end

  def is_creator?; end

  def destroy?
    return super if record.container_nodes.empty?

    forbid_with_message(I18n.t('pages.settings.advanced.delete.forum_owner'))
  end

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
    return true if user.guest?

    max = UserPolicy.new(context, user).max_allowed_pages
    return true if user.page_count < max

    forbid_with_message(I18n.t('pages.limit_reached_amount', amount: max))
  end
end
