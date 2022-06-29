# frozen_string_literal: true

class TermMenuList < ApplicationMenuList
  has_action_menu

  private

  def action_menu_items
    [
      edit_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links(include_destroy: false)
    ]
  end
end
