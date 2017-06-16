# frozen_string_literal: true
class ArgumentMenuList < MenuList
  include SettingsHelper, Menus::FollowMenuItems, Menus::ShareMenuItems
  cattr_accessor :defined_menus
  has_menus %i(follow share)

  private

  def follow_menu
    follow_menu_items(follow_types: [:reactions, :never])
  end

  def share_menu
    share_menu_items
  end
end
