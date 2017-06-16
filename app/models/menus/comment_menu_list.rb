# frozen_string_literal: true
class CommentMenuList < MenuList
  include SettingsHelper, Menus::FollowMenuItems
  cattr_accessor :defined_menus
  has_menus %i(follow)

  private

  def follow_menu
    follow_menu_items(follow_types: [:reactions, :never])
  end
end
