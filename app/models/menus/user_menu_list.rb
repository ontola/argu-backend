# frozen_string_literal: true

class UserMenuList < MenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ActionMenuItems
  cattr_accessor :defined_menus
  has_menus %i[settings]

  private

  def settings_menu
    menu_item(
      :settings,
      iri_base: -> { '' },
      menus: lambda {
        [
          setting_item(:general, href: edit_iri(resource)),
          setting_item(:profile, href: edit_iri(resource.profile)),
          setting_item(:authentication, href: edit_iri(resource, form: :authentication)),
          setting_item(:emails, href: collection_iri(resource, :email_addresses)),
          setting_item(:notifications, href: edit_iri(resource, form: :notifications)),
          setting_item(:privacy, href: edit_iri(resource, form: :privacy)),
          setting_item(:delete, href: delete_iri(resource))
        ]
      }
    )
  end
end
