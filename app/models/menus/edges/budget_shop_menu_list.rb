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

  def action_menu_items
    [
      edit_link,
      activity_link,
      search_link,
      new_update_link,
      statistics_link,
      export_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end
end