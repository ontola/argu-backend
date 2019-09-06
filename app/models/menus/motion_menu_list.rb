# frozen_string_literal: true

class MotionMenuList < ApplicationMenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  include Menus::ActionMenuItems

  has_action_menu
  has_follow_menu
  has_share_menu

  private

  def action_menu_items
    [
      decisions_link,
      comments_link,
      activity_link,
      search_link,
      new_update_link,
      edit_link,
      convert_link,
      move_link,
      statistics_link,
      export_link,
      contact_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end

  def decisions_link
    menu_item(
      :take_decision,
      image: 'fa-gavel',
      href: afe_request? ? new_iri(resource, :decisions) : collection_iri(resource, :decisions),
      policy: :decide?
    )
  end
end
