# frozen_string_literal: true

class BudgetShopMenuList < ApplicationMenuList
  include SettingsHelper
  include Helpers::FollowMenuItems
  include Helpers::ShareMenuItems
  include Helpers::ActionMenuItems

  has_action_menu
  has_follow_menu
  has_share_menu

  private

  def action_menu_items # rubocop:disable Metrics/MethodLength
    [
      edit_link,
      coupon_batch_links,
      orders_links,
      activity_link,
      search_link,
      new_update_link,
      statistics_link,
      export_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end

  def coupon_batch_links
    menu_item(
      :coupon_batches,
      image: 'fa-link',
      label: CouponBatch.label,
      href: resource.collection_iri(:coupon_batches),
      policy: :edit?
    )
  end

  def orders_links
    menu_item(
      :orders_links,
      image: 'fa-list-alt',
      label: Order.plural_label,
      href: resource.collection_iri(:orders),
      policy: :edit?
    )
  end
end
