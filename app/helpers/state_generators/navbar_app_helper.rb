module StateGenerators
  module NavbarAppHelper
    ActorItem = Struct.new(
      :display_name,
      :url,
      :id,
      :update_url,
      :default_profile_photo)

    def navbar_state
      if current_user.present? && current_user.profile.finished_intro?
        user_navbar(current_user, current_profile)
      elsif current_user.present?
        closed_navbar
      else
        guest_navbar
      end
    end

    private

    def actor_item(title, url, opts= {})
      item('actor', title, url, opts)
    end

    def closed_navbar
      {}
    end

    def forum_selector_items(user)
      sections = []
      sections << forum_membership_section if user.present?
      sections << forum_discover_section

      {
        title: t('forums.plural'),
        fa: 'fa-group',
        sections: sections,
        defaultAction: discover_forums_path,
        dropdownClass: 'navbar-forum-selector',
        triggerClass: 'navbar-item navbar-forums'
      }
    end

    def guest_navbar
      {
        forumSelector: forum_selector_items(nil),
        infoDropdown: info_dropdown_items
      }
    end

    def info_dropdown_items
      {
        title: t('about.info'),
        fa: 'fa-info',
        defaultAction: info_path(:about),
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

    def profile_dropdown_items(user, profile)
      page_index =
        if policy(Page).index?
          link_item(t('pages.management.title').capitalize, pages_user_url(user), fa: 'building')
        else
          link_item(t('pages.create'), new_page_path, fa: 'building')
        end
      drafts_index = link_item(
        t('users.drafts.title'),
        drafts_user_url(current_user),
        fa: 'pencil-square-o') if current_user.has_drafts?
      forum_management = link_item(
        t('forums.management.title'),
        forums_user_url(user),
        fa: 'group') if policy(Forum).index?
      {
        defaultAction: dual_profile_url(profile),
        trigger: {
          type: 'current_user'
        },
        sections: [
          {
            items: [
              link_item(t('show_type',
                          type: t("#{profile.profileable.class_name}.type")),
                        dual_profile_url(profile),
                        fa: 'user'),
              link_item(t('profiles.edit.title'), dual_profile_edit_url(profile), fa: 'pencil'),
              link_item(t('users.settings'), settings_url, fa: 'gear'),
              drafts_index,
              page_index,
              forum_management,
              link_item(t('sign_out'),
                        destroy_user_session_url,
                        fa: 'sign-out',
                        data: {method: 'delete', turbolinks: 'false'}),
              nil # NotABug Make sure compact! actually returns the array and not nil
            ].compact!
          },
          {
            title: t('profiles.switch'),
            type: 'actor_switcher'
          }
        ]
      }
    end

    def managed_pages_items(user)
      items = []
      items.append ActorItem.new(
        user.display_name,
        user_path(user.to_param),
        user.profile.id,
        actors_path(na: user.profile.id),
        user.profile.default_profile_photo)
      page_items = current_user.managed_pages.map do |page|
        ActorItem.new(
          page.display_name,
          page_path(page),
          page.profile.id,
          actors_path(na: page.profile.id),
          page.profile.default_profile_photo)
      end
      items.concat page_items
      items
    end

    def user_navbar(user, profile)
      {
        forumSelector: forum_selector_items(user),
        profileDropdown: profile_dropdown_items(user, profile),
        notificationDropdown: notification_dropdown_items,
        infoDropdown: info_dropdown_items
      }
    end
  end
end
