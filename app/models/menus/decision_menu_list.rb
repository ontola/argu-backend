# frozen_string_literal: true
class DecisionMenuList < MenuList
  include SettingsHelper, DecisionsHelper, Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i(actions)

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: [edit_link]
    )
  end
end
