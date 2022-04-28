# frozen_string_literal: true

class CustomFormFieldMenuList < ApplicationMenuList
  has_action_menu
  has_share_menu

  private

  def action_menu_items
    [
      edit_link,
      *trash_and_destroy_links(include_destroy: false),
      move_up_link,
      move_down_link
    ]
  end
end
