# frozen_string_literal: true

class PageMenuList < MenuList
  include SettingsHelper
  include Iriable
  cattr_accessor :defined_menus
  has_menus %i[navigations]

  private

  def navigations_menu
    forums =
      resource.forums.where("edges.path ? #{Edge.path_array(user.profile.granted_edges(root_id: resource.uuid))}")
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
end
