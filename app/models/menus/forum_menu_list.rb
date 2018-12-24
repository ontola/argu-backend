# frozen_string_literal: true

class ForumMenuList < MenuList
  include SettingsHelper
  include Menus::ActionMenuItems
  include Menus::FollowMenuItems
  include Menus::ShareMenuItems
  cattr_accessor :defined_menus
  has_menus %i[actions follow navigations share settings]

  private

  def actions_menu
    menu_item(
      :actions,
      image: 'fa-ellipsis-v',
      menus: -> { [activity_link, statistics_link, export_link, settings_link] },
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

  def settings_link
    menu_item(
      :settings,
      href: settings_iri(resource),
      image: 'fa-gear',
      link_opts: {data: {turbolinks: 'true'}},
      policy: :update?
    )
  end

  def share_menu
    share_menu_items(triggerClass: 'btn--transparant')
  end

  def settings_menu # rubocop:disable Metrics/AbcSize
    menu_item(
      :settings,
      iri_base: -> { resource.iri_path },
      menus: lambda {
        [
          setting_item(
            :general,
            label: I18n.t('forums.settings.menu.general'),
            href: edit_iri(resource)
          ),
          setting_item(
            :grants,
            label: I18n.t('forums.settings.menu.grants'),
            href: collection_iri(resource, :grants, display: :settingsTable)
          ),
          setting_item(
            :move,
            image: 'fa-sitemap',
            href: new_iri(Move.new(edge: resource).iri_path)
          ),
          setting_item(
            :delete,
            image: 'fa-trash',
            href: delete_iri(resource)
          )
        ]
      }
    )
  end
end
