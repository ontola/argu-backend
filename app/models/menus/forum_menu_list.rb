# frozen_string_literal: true

class ForumMenuList < MenuList
  include SettingsHelper
  include Menus::ActionMenuItems
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  cattr_accessor :defined_menus
  has_menus %i[actions follow navigations share]

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: -> { [activity_link, statistics_link, settings_link] },
      link_opts: {triggerClass: 'btn--transparant'}
    )
  end

  def follow_menu
    follow_menu_items(triggerClass: 'btn--transparant')
  end

  def navigations_menu
    menu_item(
      :navigations,
      menus: lambda {
        [
          menu_item(:overview, image: 'fa-th-large', href: forum_url(resource)),
          menu_item(:new_discussion, image: 'fa-plus', href: new_forum_discussion_url(resource)),
          activity_link,
          statistics_link,
          settings_link
        ]
      }
    )
  end

  def settings_link
    menu_item(
      :settings,
      href: settings_forum_url(resource),
      image: 'fa-gear',
      link_opts: {data: {turbolinks: 'true'}},
      policy: :update?
    )
  end

  def share_menu
    share_menu_items(triggerClass: 'btn--transparant')
  end
end
