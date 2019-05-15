# frozen_string_literal: true

class UserMenuList < ApplicationMenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ActionMenuItems

  has_menu :settings,
           iri_base: -> { '/u' },
           menus: -> { setting_menu_items }

  private

  def setting_menu_items # rubocop:disable Metrics/AbcSize
    [
      setting_item(:general, href: edit_iri(resource)),
      setting_item(:profile, href: edit_iri(resource.profile)),
      setting_item(:authentication, href: edit_iri(resource, form: :authentication)),
      setting_item(:emails, href: collection_iri(resource, :email_addresses, display: :settingsTable)),
      setting_item(:notifications, href: edit_iri(resource, form: :notifications)),
      setting_item(:privacy, href: edit_iri(resource, form: :privacy)),
      setting_item(:delete, href: delete_iri(resource))
    ]
  end
end
