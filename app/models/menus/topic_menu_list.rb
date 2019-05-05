# frozen_string_literal: true

class TopicMenuList < ApplicationMenuList
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
      comments_link,
      activity_link,
      search_link,
      new_update_link,
      edit_link,
      convert_link,
      move_link,
      statistics_link,
      export_link,
      contact_link,
      *trash_and_destroy_links
    ]
  end
end
