# frozen_string_literal: true
class BlogPostMenuList < MenuList
  include SettingsHelper, Menus::ShareMenuItems
  cattr_accessor :defined_menus
  has_menus %i(share)

  def share_menu
    share_menu_items
  end
end
