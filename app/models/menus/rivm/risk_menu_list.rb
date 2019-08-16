# frozen_string_literal: true

class RiskMenuList < ApplicationMenuList
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  include Menus::ActionMenuItems

  has_action_menu
  has_follow_menu
  has_share_menu

  private

  def action_menu_items
    [
      comments_link,
      activity_link,
      search_link,
      edit_link,
      statistics_link,
      export_link
    ]
  end
end
