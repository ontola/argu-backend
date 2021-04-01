# frozen_string_literal: true

class BudgetShopMenuList < ApplicationMenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  include Menus::ActionMenuItems

  has_action_menu
  has_follow_menu
  has_share_menu

  private

  def action_menu_items # rubocop:disable Metrics/MethodLength
    [
      edit_link,
      coupon_badges_links,
      activity_link,
      search_link,
      new_update_link,
      statistics_link,
      export_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end

  def coupon_badges_links
    menu_item(
      :coupon_badges,
      image: 'fa-link',
      label: I18n.t('coupon_badges.type'),
      href: collection_iri(resource, :coupon_badges),
      policy: :edit?
    )
  end
end
