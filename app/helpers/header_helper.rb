# frozen_string_literal: true

module HeaderHelper
  include NotificationsHelper
  include DropdownHelper

  def suggested_forums
    @suggested_forums ||= Setting.get('suggested_forums')&.split(',')&.map(&:strip) || []
  end

  def profile_dropdown_items
    items =
      if current_user.url.present?
        [
          link_item(t('show_type', type: t("#{current_profile.profileable.class_name}.type")),
                    dual_profile_url(current_profile),
                    fa: 'user'),
          link_item(t('profiles.edit.title'), settings_user_url(tab: :profile), fa: 'pencil')
        ]
      else
        [link_item(t('profiles.setup.link'), setup_users_url, fa: 'user')]
      end
    items << link_item(t('users.settings.title'), settings_user_url, fa: 'gear')
    items << link_item(t('users.drafts.title'), drafts_user_url(current_user), fa: 'pencil-square-o')
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
                       fa: 'sign-out',
                       data: {method: 'delete', turbolinks: 'false'})

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
      sections: [{items: items}]
    }
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
      .includes(:default_profile_photo, :shortname)
      .select { |f| suggested_forums.include?(f.shortname.shortname) }
      .first(limit)
      .each do |forum|
      items << link_item(
        forum.display_name,
        forum_path(forum),
        data: {turbolinks: false_unless_iframe},
        image: forum.default_profile_photo.url(:icon)
      )
    end
    items
  end

  def profile_favorite_items
    ids = current_user.favorite_forum_ids
    Shortname
      .shortname_owners_for_klass('Forum', ids)
      .includes(owner: :default_profile_photo)
      .map do |shortname|
        link_item(
          shortname.owner.display_name,
          forum_path(shortname.shortname),
          data: {turbolinks: false_unless_iframe},
          image: shortname.owner.default_profile_photo.url(:icon)
        )
      end
  end

  def info_dropdown_items
    {
      title: t('about.info'),
      fa: 'fa-info',
      defaultAction: info_path(:about),
      sections: [
        {
          items: [
            link_item(t('about.about'), i_about_path),
            link_item(t('about.team'), info_path(:team)),
            link_item(t('about.governments'), info_path(:governments)),
            link_item(t('press_media'), 'https://argu.pr.co'),
            link_item(t('help_support'), 'https://argu.freshdesk.com/support/home'),
            link_item(t('about.contact'), info_path(:contact))
          ]
        }
      ],
      triggerClass: 'navbar-item'
    }
  end

  def actor_item(title, url, opts = {})
    item('actor', title, url, opts)
  end
end
