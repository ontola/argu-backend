# frozen_string_literal: true

class ArgumentMenuList < ApplicationMenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  include Menus::ActionMenuItems

  has_action_menu
  has_follow_menu follow_types: %i[reactions never]
  has_share_menu

  private

  def action_menu_items
    [activity_link, edit_link, *trash_and_destroy_links, contact_link]
  end
end
