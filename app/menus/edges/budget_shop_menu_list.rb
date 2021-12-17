# frozen_string_literal: true

class BudgetShopMenuList < ApplicationMenuList
  include SettingsHelper

  has_action_menu
  has_follow_menu
  has_share_menu
  has_tabs_menu

  private

  def action_menu_items
    [
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
      dialog: true,
      image: 'fa-link',
      label: CouponBatch.label,
      href: resource.collection_iri(:coupon_batches),
      policy: :edit?
    )
  end

  def offers_links
    menu_item(
      :offers,
      image: 'fa-shopping-cart',
      label: Offer.plural_label,
      href: resource.collection_iri(:offers)
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

  def tabs_menu_items
    [
      offers_links,
      comments_link,
      orders_links,
      coupon_batch_links,
      edit_link,
      activity_link
    ]
  end
end
