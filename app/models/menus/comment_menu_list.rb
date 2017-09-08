# frozen_string_literal: true

class CommentMenuList < MenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i[actions follow]

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: [edit_link, trash_and_destroy_links]
    )
  end

  def follow_menu
    follow_menu_items(follow_types: %i[reactions never])
  end
end
