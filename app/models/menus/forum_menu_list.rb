# frozen_string_literal: true
class ForumMenuList < MenuList
  include SettingsHelper, Menus::FollowMenuItems, Menus::ShareMenuItems
  cattr_accessor :defined_menus
  has_menus %i(follow navigations share)

  private

  def follow_menu
    follow_menu_items(triggerClass: 'btn--transparant')
  end

  def navigations_menu
    menu_item(
      :navigations,
      menus: [
        menu_item(:motions, image: 'fa-lightbulb-o', href: forum_canonical_motions_url(resource)),
        menu_item(:questions, image: 'fa-question', href: forum_canonical_questions_url(resource)),
        menu_item(:settings, image: 'fa-gear', href: settings_forum_url(resource), policy: :update?)
      ]
    )
  end

  def share_menu
    share_menu_items(triggerClass: 'btn--transparant')
  end
end
