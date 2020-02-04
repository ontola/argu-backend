# frozen_string_literal: true

class InterventionTypeMenuList < ApplicationMenuList
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  include Menus::ActionMenuItems

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
      export_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end
end
