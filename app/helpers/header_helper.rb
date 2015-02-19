module HeaderHelper

  def forum_selector_items
    {
        title: t('home_title'),
        fa: 'fa-tags',
        fa_after: 'fa-angle-down',
        sections: [
            {
                items: forum_selector_memberships
            }
        ]
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
        title: current_profile.display_name,
        image: {
            url: current_profile.profile_photo.url(:icon),
            className: 'profile-picture--navbar'
        },
        sections: [
          {
              items: [
                  link_item(t('profiles.display'), profile_path(current_profile.username), fa: 'user'),
                  link_item(t('users_show_title'), settings_url, fa: 'gear'),
                  link_item(t('devise.invitations.link'), new_user_invitation_path, fa: 'bullhorn'),
                  link_item(t('sign_out'), destroy_user_session_url, fa: 'sign-out')
              ]
          },
          {
              title: t('profiles.switch'),
              items: managed_pages_items
          }
        ]
    }
  end

  def info_dropdown_items
    {
        title: t('about.title'),
        fa: 'fa-info',
        sections: [
          {
              items: [
                  link_item(t('about.vision'), about_path),
                  link_item(t('about.how_argu_works'), how_argu_works_path),
                  link_item(t('about.governments'), governments_path),
                  link_item(t('about.team'), team_path  )
              ]
          }
        ]
    }
  end

  def link_item(title, url, opts = {})
    item = {
        type: 'link',
        title: title,
        url: url
    }

    image = opts.delete(:image) if opts[:image].present?
    item[:image]= {url: image} if image.present?
    item[:fa]= "fa-#{opts.delete :fa}" if opts[:fa].present?
    item.merge(opts)
  end

  def managed_pages_items
    items = []
    if current_user.managed_pages.present?
      items << link_item(current_user.display_name, actors_path(na: current_user.profile.id), image: current_profile.profile_photo.url(:icon))
      current_user.managed_pages.each do |p|
        items << link_item(p.display_name, actors_path(na: p.profile.id), image: p.profile.profile_photo.url(:icon))
      end
    end
    items
  end
end