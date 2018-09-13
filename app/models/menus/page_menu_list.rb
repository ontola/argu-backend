# frozen_string_literal: true

class PageMenuList < MenuList
  include SettingsHelper
  include Iriable
  cattr_accessor :defined_menus
  has_menus %i[navigations settings]

  private

  def forums
    @forums ||=
      EdgePolicy::Scope.new(user_context, resource.forums)
        .resolve
        .includes(:default_profile_photo, :shortname)
  end

  def navigations_menu
    menu_item(
      :navigations,
      menus: lambda {
        [
          menu_item(
            :settings,
            image: 'fa-gear',
            href: settings_page_url(resource),
            policy: :update?
          ),
          *custom_menu_items(:navigations, resource),
          menu_item(
            :forums,
            label: forums.count == 1 ? I18n.t('forums.type') : I18n.t('forums.plural'),
            type: NS::ARGU[:MenuSection],
            menus:
              if forums.count == 1
                forums.first.menu(user_context, :navigations).menus
              else
                -> { forums.map { |child| navigation_item(child) } }
              end
          )
        ]
      }
    )
  end

  def navigation_item(record)
    menu_item(
      record.url.to_sym,
      href: record.iri,
      label: record.display_name,
      menus: record.menu(user_context, :navigations).menus,
      image: record.try(:default_profile_photo),
      policy: :show?,
      policy_resource: record
    )
  end

  def settings_menu
    menu_item(
      :settings,
      iri_base: -> { resource.iri_path },
      menus: lambda {
        [
          setting_item(:profile, label: I18n.t('pages.settings.menu.general'), href: edit_iri(resource.profile)),
          setting_item(:forums, label: I18n.t('pages.settings.menu.forums'), href: collection_iri(resource, :forums)),
          setting_item(:groups, label: I18n.t('pages.settings.menu.groups'), href: collection_iri(resource, :groups)),
          setting_item(:advanced, label: I18n.t('pages.settings.menu.advanced'), href: edit_iri(resource)),
          setting_item(
            :shortnames,
            label: I18n.t('pages.settings.menu.shortnames'),
            href: collection_iri(resource, :shortnames)
          )
        ]
      }
    )
  end
end
