# frozen_string_literal: true

class UserMenuList < ApplicationMenuList
  include Menus::FollowMenuItems
  include Menus::ActionMenuItems

  has_menu :profile,
           iri_base: -> { resource.iri_path },
           menus: -> { profile_menu_items }

  private

  def profile_menu_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    items = []
    items << menu_item(:activity, href: feeds_iri(resource)) if resource == user || resource.show_feed
    if resource == user
      items.concat [
        menu_item(:notifications, href: Notification.root_collection.iri),
        menu_item(:drafts, label: I18n.t('users.drafts.title'), href: RDF::DynamicURI(drafts_user_url(resource))),
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
