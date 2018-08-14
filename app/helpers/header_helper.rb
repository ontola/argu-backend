# frozen_string_literal: true

module HeaderHelper
  include NotificationsHelper
  include DropdownHelper

  def suggested_forums
    @suggested_forums ||= Setting.get('suggested_forums')&.split(',')&.map(&:strip) || []
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

  def profile_dropdown_sections
    items =
      if current_user.url.present?
        [
          link_item(t('show_type', type: t("#{current_profile.profileable.class_name}.type")),
                    dual_profile_url(current_profile),
                    fa: 'user'),
          link_item(t('profiles.edit.title'), settings_user_url(tab: :profile), fa: 'pencil-alt')
        ]
      else
        [link_item(t('profiles.setup.link'), setup_users_url, fa: 'user')]
      end
    items << link_item(t('users.settings.title'), settings_user_url, fa: 'cog')
    items << link_item(t('users.drafts.title'), drafts_user_url(current_user), fa: 'edit')
    items << if current_user.page_management?
               link_item(t('pages.management.title').capitalize, pages_user_url(current_user), fa: 'building')
             else
               link_item(t('pages.create'), new_page_path, fa: 'building')
             end
    if current_user.forum_management?
      items << link_item(t('forums.management.title'), forums_user_url(current_user), fa: 'group')
    end
    items << link_item(t('sign_out'),
                       destroy_user_session_url,
                       fa: 'sign-out-alt',
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
    items = []
    Forum
      .public_forums
      .includes(:default_profile_photo, :shortname, root: :shortname)
      .where(edges: {uuid: suggested_forums})
      .first(limit)
      .each do |forum|
      items << link_item(
        forum.display_name,
        forum.iri_path,
        data: {turbolinks: false_unless_iframe},
        image: forum.default_profile_photo.url(:icon)
      )
    end
    items
  end

  def profile_favorite_items
    return [] if current_user.guest?
    current_user
      .favorite_forums
      .includes(:default_profile_photo, :shortname, root: :shortname)
      .map do |forum|
        link_item(
          forum.display_name,
          forum.iri_path,
          data: {turbolinks: false_unless_iframe},
          image: forum.default_profile_photo.url(:icon)
        )
      end
  end

  def actor_item(title, url, opts = {})
    item('actor', title, url, opts)
  end
end
