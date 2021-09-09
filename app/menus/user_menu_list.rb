# frozen_string_literal: true

class UserMenuList < ApplicationMenuList
  include Helpers::FollowMenuItems
  include Helpers::ActionMenuItems

  has_menu :settings,
           iri_base: -> { resource.root_relative_iri },
           menus: -> { settings_menu_items }

  private

  def settings_menu_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    items = []
    items << menu_item(:activity, href: feeds_iri(resource)) if resource == user || resource.show_feed
    if resource == user
      items.concat [
        menu_item(:notifications, href: Notification.root_collection.iri),
        menu_item(:drafts, label: I18n.t('users.drafts.title'), href: drafts_iri),
        menu_item(:profile, label: I18n.t('menus.default.profile'), href: resource.action(:profile).iri),
        menu_item(:settings, label: I18n.t('menus.default.settings'), href: edit_iri(resource))
      ]
    end
    if user.is_staff?
      items << menu_item(:destroy, href: delete_iri(resource), label: I18n.t('users.settings.menu.destroy'))
    end
    items
  end
end
