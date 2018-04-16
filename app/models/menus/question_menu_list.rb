# frozen_string_literal: true

class QuestionMenuList < MenuList
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
      menus: lambda {
        [
          comments_link,
          activity_link,
          new_update_link,
          edit_link,
          move_link,
          statistics_link,
          export_link,
          contact_link,
          *trash_and_destroy_links
        ]
      }
    )
  end

  def follow_menu
    follow_menu_items
  end

  def share_menu
    share_menu_items
  end
end
