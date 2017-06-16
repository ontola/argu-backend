# frozen_string_literal: true
class QuestionMenuList < MenuList
  include SettingsHelper, Menus::FollowMenuItems, Menus::ShareMenuItems
  cattr_accessor :defined_menus
  has_menus %i(follow share)

  private

  def follow_menu
    follow_menu_items
  end

  def share_menu
    share_menu_items
  end
end
