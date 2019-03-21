# frozen_string_literal: true

class ContainerNodeMenuList < MenuList
  include SettingsHelper
  include Menus::ActionMenuItems
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems

  cattr_accessor :defined_menus
  has_menus %i[]

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: -> { [activity_link, search_link, statistics_link, export_link, move_link, destroy_link, edit_link] },
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
          menu_item(:overview, image: 'fa-th-large', href: resource.iri),
          activity_link,
          statistics_link,
          settings_link
        ]
      }
    )
  end

  def edit_link
    menu_item(
      :edit,
      image: 'fa-gear',
      label: I18n.t('menus.default.settings'),
      href: edit_iri(resource),
      policy: :update?
    )
  end

  def share_menu
    share_menu_items(triggerClass: 'btn--transparant')
  end
end
