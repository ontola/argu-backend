# frozen_string_literal: true

class DecisionMenuList < ApplicationMenuList
  include SettingsHelper
  include DecisionsHelper
  include Menus::ActionMenuItems

  has_action_menu

  private

  def action_menu_items
    [edit_link]
  end
end
