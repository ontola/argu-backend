# frozen_string_literal: true
class ProjectMenuList < MenuList
  include SettingsHelper, Menus::FollowMenuItems, Menus::ShareMenuItems, Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i(actions follow share)

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: [activity_link, new_update_link, edit_link, trash_and_destroy_links]
    )
  end

  def follow_menu
    follow_menu_items
  end

  def share_menu
    share_menu_items
  end
end
