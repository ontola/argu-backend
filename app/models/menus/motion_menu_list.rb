# frozen_string_literal: true

class MotionMenuList < MenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  include Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i[actions follow share]

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: [
        decisions_link,
        comments_link,
        activity_link,
        new_update_link,
        edit_link,
        statistics_link,
        trash_and_destroy_links
      ]
    )
  end

  def decisions_link
    menu_item(
      :take_decision,
      image: 'fa-gavel',
      href: motion_decisions_url(resource),
      policy: :decide?
    )
  end

  def follow_menu
    follow_menu_items
  end

  def share_menu
    share_menu_items
  end
end
