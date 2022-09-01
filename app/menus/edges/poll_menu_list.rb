# frozen_string_literal: true

class PollMenuList < ApplicationMenuList
  has_action_menu
  has_follow_menu
  has_share_menu
  has_tabs_menu

  private

  def action_menu_items
    [
      move_link,
      statistics_link,
      permissions_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end

  def tabs_menu_items
    [
      comments_link,
      edit_link,
      activity_link
    ]
  end
end
