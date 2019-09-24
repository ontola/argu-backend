# frozen_string_literal: true

module HeaderHelper
  include NotificationsHelper
  include DropdownHelper

  def suggested_forums
    @suggested_forums ||= Setting.get('suggested_forums')&.split(',')&.map(&:strip) || []
  end

  def forum_item(forum)
    user_context.with_root(forum.parent) do
      link_item(
        forum.display_name,
        forum.iri,
        data: {turbolinks: false},
        image: forum.default_profile_photo.url(:icon)
      )
    end
  end

  def profile_dropdown_items
    {
      defaultAction: dual_profile_url(current_profile),
      trigger: {
        type: 'current_user',
        title: truncate(current_profile.display_name, length: 20),
        profile_photo: {
          url: current_profile.default_profile_photo.url(:icon),
          className: 'profile-picture--navbar'
        },
        triggerClass: 'navbar-item navbar-profile'
      },
      dropdownClass: 'navbar-profile-selector',
      sections: profile_dropdown_sections
    }
  end

  def profile_dropdown_sections # rubocop:disable Metrics/AbcSize
    items =
      if current_user.url.present?
        [
          link_item(t('show_type', type: t("#{current_profile.profileable.class_name}.type")),
                    dual_profile_url(current_profile),
                    fa: 'user'),
          link_item(t('profiles.edit.title'), settings_iri('/u', tab: :profile), fa: 'pencil')
        ]
      else
        [link_item(t('profiles.setup.link'), setup_users_url, fa: 'user')]
      end
    items << link_item(t('users.settings.title'), settings_iri('/u'), fa: 'gear')
    items << link_item(t('users.drafts.title'), collection_iri(current_user, :drafts), fa: 'pencil-square-o')
    if current_user.page_management?
      items << link_item(t('pages.management.title').capitalize, collection_iri(current_user, :pages), fa: 'building')
    end
    if current_user.forum_management?
      items << link_item(t('forums.management.title'), collection_iri(current_user, :forums), fa: 'group')
    end
    items << link_item(t('sign_out'),
                       destroy_user_session_url,
                       fa: 'sign-out',
                       data: {method: 'delete', turbolinks: 'false'})
    [{items: items}]
  end

  def notification_dropdown_items
    dropdown_options('',
                     [{
                       type: 'notifications',
                       unread: unread_notification_count,
                       lastNotification: nil,
                       notifications: [],
                       loadMore: true
                     }],
                     fa: 'fa-bell',
                     triggerClass: 'navbar-item',
                     contentClassName: 'notifications notification-container')
  end

  def public_forum_items(limit = 10)
    Forum
      .public_forums
      .includes(:default_profile_photo, :shortname, root: :shortname)
      .where(edges: {uuid: suggested_forums})
      .first(limit)
      .map(&method(:forum_item))
  end

  def profile_favorite_items
    return [] if current_user.guest?
    current_user
      .favorite_forums
      .includes(:default_profile_photo, :shortname, root: :shortname)
      .map(&method(:forum_item))
  end

  def actor_item(title, url, opts = {})
    item('actor', title, url, opts)
  end
end
