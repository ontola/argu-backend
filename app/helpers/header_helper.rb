module HeaderHelper
  include DropdownHelper

  def suggested_forums
    @suggested_forums ||= Forum.where("id NOT IN (#{current_profile.memberships_ids || '0'}) AND visibility = #{Forum.visibilities[:open]}") if current_user.present?
  end

  def profile_dropdown_items
    @profile = current_profile
    {
        trigger: {
            type: 'current_user',
            title: truncate(current_profile.display_name, length: 20),
            profile_photo: {
                url: current_profile.profile_photo.url(:icon),
                className: 'profile-picture--navbar'
            },
            triggerClass: 'navbar-item navbar-profile'
        },
        sections: [
          {
              items: [
                  link_item(t('show_type', type: t("#{current_profile.profileable.class_name}.type")), dual_profile_url(current_profile), fa: 'user'),
                  link_item(t('profiles.edit.title'), dual_profile_edit_url(current_profile), fa: 'pencil'),
                  link_item(t('users.settings'), settings_url, fa: 'gear'),
                  policy(Page).index? ? link_item(t('pages.management.title').capitalize, pages_user_url(current_user), fa: 'building') : link_item(t('pages.create'), new_page_path, fa: 'building'),
                  (link_item(t('forums.management.title'), forums_user_url(current_user), fa: 'group') if policy(Forum).index? ),
                  link_item(t('sign_out'), destroy_user_session_url, fa: 'sign-out', data: {method: 'delete', 'skip-pjax' => 'true'}),
                  nil #NotABug Make sure compact! actually returns the array and not nil
              ].compact!
          },
          {
              title: t('profiles.switch'),
              items: managed_pages_items
          }
        ]
    }
  end

  def notification_dropdown_items
    dropdown_options('', [{
                            type: 'notifications',
                            unread: policy_scope(Notification).where('read_at is NULL').order(created_at: :desc).count,
                            lastNotification: nil,
                            notifications: [],
                            loadMore: true
                        }],
                     trigger: {
                         type: 'notifications',
                         triggerClass: 'navbar-item'
                     },
                     fa: 'fa-bell',
                     triggerClass: 'navbar-item',
                     contentClassName: 'notifications notification-container')
  end

  def public_forum_items(limit= 10)
    items = []
    Forum.top_public_forums(limit)
        .select { |f| ['nederland', 'utrecht', 'houten', 'feedback'].include?(f.shortname.shortname) }
        .each do |forum|
      items << link_item(forum.display_name, forum_path(forum), image: forum.profile_photo.url(:icon))
    end
    items
  end

  def profile_membership_items
    ids = current_profile.present? ? current_profile.memberships.pluck(:forum_id) : []
    Shortname.shortname_owners_for_klass('Forum', ids).map do |shortname|
      link_item(shortname.owner.display_name, forum_path(shortname.shortname), image: shortname.owner.profile_photo.url(:icon))
    end
  end

  def info_dropdown_items
    {
        title: t('about.info'),
        fa: 'fa-info',
        sections: [
          {
              items: [
                  link_item(t('about.vision'), info_path(:about)),
                  link_item(t('about.how_argu_works'), how_argu_works_path),
                  link_item(t('about.team'), info_path(:team)),
                  link_item(t('about.governments'), info_path(:governments)),
                  link_item(t('about.lobby_organizations'), info_path(:lobby_organizations)),
                  link_item(t('press_media'), 'https://argu.pr.co'),
                  link_item(t('help_support'), 'https://argu.freshdesk.com/support/home'),
                  link_item(t('about.contact'), info_path(:contact))
              ]
          }
        ],
        triggerClass: 'navbar-item'
    }
  end

  def actor_item(title, url, opts= {})
    item('actor', title, url, opts)
  end

  def managed_pages_items
    items = []
    if current_user.managed_pages.present?
      items << actor_item(current_user.display_name, actors_path(na: current_user.profile.id, format: :json), image: current_user.profile.profile_photo.url(:icon), data: { method: 'put', 'skip-pjax' => 'true'})
      current_user.managed_pages.includes(:profile).each do |p|
        items << actor_item(p.profile.name, actors_path(na: p.profile.id, format: :json), image: p.profile.profile_photo.url(:icon), data: { method: 'put', 'skip-pjax' => 'true'})
      end
    end
    items
  end
end
