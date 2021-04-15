# frozen_string_literal: true

class TermMenuList < ApplicationMenuList
  include Menus::ActionMenuItems

  has_action_menu

  private

  def action_menu_items
    [
      copy_share_link(resource.iri),
      edit_link,
      destroy_link
    ]
  end
end
