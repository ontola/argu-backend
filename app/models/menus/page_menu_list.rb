# frozen_string_literal: true

class PageMenuList < MenuList
  include SettingsHelper
  include Iriable
  cattr_accessor :defined_menus
  has_menus %i[navigations]

  private

  def navigations_menu
    forums = policy_scope(resource.forums.includes(:shortname, :edge, :default_profile_photo))
    children = forums + resource.sources
    section_items =
      if children.count == 1
        children.first.menu(user_context, :navigations).menus
      else
        children.map { |child| navigation_item(child) }
      end
    menu_item(
      :navigations,
      menus: [
        menu_item(
          :settings,
          image: 'fa-gear',
          href: settings_page_url(resource)
        ),
        menu_item(
          :forums,
          label: children.count == 1 ? I18n.t('forums.type') : I18n.t('forums.plural'),
          type: NS::ARGU[:MenuSection],
          menus: section_items
        )
      ]
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
end
