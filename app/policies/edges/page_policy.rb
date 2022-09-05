# frozen_string_literal: true

class PagePolicy < EdgePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[display_name name url iri_prefix language]
  permit_attributes %i[primary_container_node_id delete], new_record: false
  permit_attributes %i[confirmation_text], new_record: true
  permit_attributes %i[requires_intro],
                    new_record: false
  permit_attributes %i[matomo_site_id matomo_host matomo_cdn
                       piwik_pro_site_id piwik_pro_host google_tag_manager google_uac],
                    grant_sets: %i[administrator],
                    feature_enabled: :user_tracking,
                    new_record: false
  permit_attributes %i[tier], staff: true

  def permitted_tabs
    tabs = []
    tabs.concat %i[general theme container_nodes users groups shortnames custom_menu_items banners] if update?
    tabs.concat %i[vocabularies] if staff?
    tabs
  end

  def public_resource?
    true
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

  def theme?
    can_update = update?

    return can_update unless can_update
    return forbid_wrong_tier unless feature_enabled?(:custom_style)

    true
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

    forbid_with_message(I18n.t('pages.limit_reached_amount', count: max))
  end
end
