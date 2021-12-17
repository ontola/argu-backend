# frozen_string_literal: true

class ProjectMenuList < ApplicationMenuList
  has_action_menu
  has_follow_menu
  has_share_menu

  private

  def action_menu_items
    [
      edit_link,
      move_link,
      new_update_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end
end
