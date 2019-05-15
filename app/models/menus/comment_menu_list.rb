# frozen_string_literal: true

class CommentMenuList < ApplicationMenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ActionMenuItems

  has_action_menu
  has_follow_menu follow_types: %i[reactions never]

  private

  def action_menu_items
    [edit_link, *trash_and_destroy_links]
  end
end
