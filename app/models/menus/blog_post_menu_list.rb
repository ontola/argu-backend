# frozen_string_literal: true

class BlogPostMenuList < ApplicationMenuList
  include SettingsHelper
  include Menus::ShareMenuItems
  include Menus::ActionMenuItems

  has_action_menu
  has_share_menu

  private

  def action_menu_items
    [edit_link, *trash_and_destroy_links]
  end
end
