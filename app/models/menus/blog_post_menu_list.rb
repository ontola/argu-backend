# frozen_string_literal: true
class BlogPostMenuList < MenuList
  include SettingsHelper, Menus::ShareMenuItems, Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i(actions share)

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: [edit_link, trash_and_destroy_links]
    )
  end

  def share_menu
    share_menu_items
  end
end
