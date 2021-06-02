# frozen_string_literal: true

class PhaseMenuList < ApplicationMenuList
  include Helpers::ActionMenuItems

  has_action_menu

  private

  def action_menu_items
    [
      edit_link,
      widgets_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end
end