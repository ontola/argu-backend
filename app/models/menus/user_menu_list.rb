# frozen_string_literal: true

class UserMenuList < ApplicationMenuList
  include SettingsHelper
  include Menus::FollowMenuItems
  include Menus::ActionMenuItems

  has_menu :settings,
           iri_base: -> { '/u' },
           menus: -> { setting_menu_items }
  has_menu :profile,
           iri_base: -> { resource.iri_path },
           menus: -> { profile_menu_items }

  private

  def profile_menu_items # rubocop:disable Metrics/AbcSize
    items = []
    items << menu_item(:activity, href: feeds_iri(resource)) if resource == user || resource.show_feed
    if resource == user
      items.concat [
        menu_item(:notifications, href: Notification.root_collection.iri),
        menu_item(:drafts, label: I18n.t('users.drafts.title'), href: RDF::DynamicURI(drafts_user_url(resource)))
      ]
    end
    items
  end

  def setting_menu_items # rubocop:disable Metrics/AbcSize
    [
      setting_item(:general, href: edit_iri(resource)),
      setting_item(:profile, href: edit_iri(resource.profile)),
      setting_item(:authentication, href: edit_iri(resource, form: :authentication)),
      setting_item(:notifications, href: edit_iri(resource, form: :notifications)),
      setting_item(:privacy, href: edit_iri(resource, form: :privacy))
    ]
  end
end
