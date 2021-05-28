# frozen_string_literal: true

class MeasureMenuList < ApplicationMenuList
  include Helpers::FollowMenuItems
  include Helpers::ShareMenuItems
  include Helpers::ActionMenuItems

  has_action_menu
  has_follow_menu
  has_share_menu

  private

  def action_menu_items
    [
      activity_link,
      search_link,
      edit_link,
      statistics_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end
end
