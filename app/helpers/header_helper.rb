module HeaderHelper
  include DropdownHelper

  def forum_selector_items
    {
        title: t('forums.mine'),
        fa: 'fa-group',
        fa_after: 'fa-angle-down',
        sections: [
            {
                items: forum_selector_memberships
            }
        ],
        triggerClass: 'navbar-item'
    }
  end

  def forum_selector_memberships
    items = []
    current_user.profile.memberships.each do |m|
      items << link_item(m.forum.display_name, forum_path(m.forum), image: m.forum.profile_photo.url(:icon))
    end
    items << link_item(t('forums.discover'), forums_path, fa: 'compass', divider: 'top')
  end

  # Label for the home button
  def home_text
    current_scope.model.try(:display_name) || t("home_title")
  end

  def suggested_forums
    @suggested_forums ||= Forum.where("id NOT IN (#{current_profile.memberships_ids || '0'}) AND visibility = #{Forum.visibilities[:open]}") if current_user.present?
  end

  def profile_dropdown_items
    {
        trigger: {
            type: 'current_user',
            title: current_profile.display_name,
            image: {
                url: current_profile.profile_photo.url(:icon),
                className: 'profile-picture--navbar'
            },
            triggerClass: 'navbar-item'
        },
        sections: [
          {
              items: [
                  link_item(t('profiles.display'), dual_profile_path(current_profile), fa: 'user'),
                  link_item(t('users_show_title'), settings_url, fa: 'gear'),
                  link_item(t('devise.invitations.link'), new_user_invitation_path, fa: 'bullhorn'),
                  link_item(t('sign_out'), destroy_user_session_url, fa: 'sign-out', data: {method: 'delete', 'skip-pjax' => 'true'})
              ]
          },
          {
              title: t('profiles.switch'),
              items: managed_pages_items
          }
        ]
    }
  end

  def notification_dropdown_items(items=[])
    dropdown_options('', [
                        {type: 'notifications', unread: policy_scope(Notification).where('read_at is NULL').order(created_at: :desc).count, lastNotification: (items.first && items.first[:created_at]), notifications: items}
                       ],
                     trigger: {
                         type: 'notifications',
                         triggerClass: 'navbar-item'
                     },
                     fa: 'fa-circle',
                     triggerClass: 'navbar-item')
  end

  def info_dropdown_items
    {
        title: t('about.title'),
        fa: 'fa-info',
        sections: [
          {
              items: [
                  link_item(t('about.vision'), about_path),
                  link_item(t('about.team'), team_path  ),
                  link_item(t('about.governments'), governments_path),
                  link_item(t('about.how_argu_works'), how_argu_works_path),
                  link_item(t('intro.start'), nil, className: 'intro-trigger', data: {:'skip-pjax' => true})
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
      items << actor_item(current_user.display_name, actors_path(na: current_user.profile.id), image: current_user.profile.profile_photo.url(:icon), data: { method: 'put', 'skip-pjax' => 'true'})
      current_user.managed_pages.each do |p|
        items << actor_item(p.display_name, actors_path(na: p.profile.id), image: p.profile.profile_photo.url(:icon), data: { method: 'put', 'skip-pjax' => 'true'})
      end
    end
    items
  end
end