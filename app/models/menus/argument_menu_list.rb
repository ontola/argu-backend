# frozen_string_literal: true

class ArgumentMenuList < MenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  include Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i[actions follow share]

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: [activity_link, edit_link, trash_and_destroy_links]
    )
  end

  def follow_menu
    follow_menu_items(follow_types: %i[reactions never])
  end

  def share_menu
    share_menu_items
  end
end
