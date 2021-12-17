# frozen_string_literal: true

class CustomFormMenuList < ApplicationMenuList
  has_action_menu
  has_share_menu

  private

  def action_menu_items
    [
      activity_link,
      edit_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links(include_destroy: false)
    ]
  end
end
