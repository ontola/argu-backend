# frozen_string_literal: true

class AppMenuList < ApplicationMenuList # rubocop:disable Metrics/ClassLength
  include SettingsHelper
  include LanguageHelper

  has_menu :info,
           label: I18n.t('about.info'),
           image: 'fa-info',
           link_opts: -> { {triggerClass: 'navbar-item', defaultAction: RDF::URI(i_about_url)} },
           menus: -> { info_menu_items }
  has_menu :user,
           label: -> { resource.display_name },
           image: -> { resource.profile.default_profile_photo.thumbnail },
           link_opts: -> { {triggerClass: 'navbar-item', defaultAction: user_url(user)} },
           menus: -> { user_menu_items }

  def iri_path(opts = {})
    expand_uri_template('menu_lists_iri', opts.merge(parent_iri: '/apex'))
  end

  private

  def info_menu_items # rubocop:disable Metrics/AbcSize
    blog_url = RDF::URI("https://#{RequestStore.store[:old_frontend] ? '' : 'app.'}argu.co/argu/blog/posts")
    [
      menu_item(:about, label: I18n.t('about.about'), href: RDF::URI(i_about_url)),
      menu_item(:team, label: I18n.t('about.team'), href: RDF::URI(info_url(:team))),
      menu_item(:blog, label: I18n.t('about.blog'), href: blog_url),
      menu_item(:governments, label: I18n.t('about.governments'), href: RDF::URI(info_url(:governments))),
      menu_item(:press_media, label: I18n.t('press_media'), href: RDF::URI('https://argu.pr.co')),
      menu_item(:support, label: I18n.t('help_support'), href: RDF::URI('https://argu.freshdesk.com/support/home')),
      menu_item(:contact, label: I18n.t('about.contact'), href: RDF::URI(info_url(:contact))),
      afe_request? ? menu_item(:discover, label: I18n.t('pages.discover'), href: collection_iri(nil, :pages)) : nil,
      afe_request? ? language_menu_item : nil
    ]
  end

  def edit_profile_link
    afe_request? ? "#{settings_user_users_url}#profile" : settings_user_users_url(tab: :profile)
  end

  def language_menu_item
    menu_item(
      :language,
      label: I18n.t('set_language'),
      href: RDF::DynamicURI(expand_uri_template(:languages_iri, with_hostname: true))
    )
  end

  def public_pages
    return @public_pages if instance_variable_defined?('@public_pages')
    page_ids =
      Forum
        .joins(:parent)
        .where(edges: {uuid: Setting.get('suggested_forums')&.split(',')})
        .pluck('parents_edges.uuid')
    @public_pages ||=
      Page.where(uuid: page_ids).includes(:shortname, profile: :default_profile_photo)
  end

  def sign_out_menu_item
    menu_item(:signout,
              action: NS::ONTOLA['actions/logout'],
              label: I18n.t('sign_out'),
              href: destroy_user_session_url,
              image: 'fa-sign-out')
  end

  def user_base_items
    if resource.url.present?
      [
        menu_item(
          :show, label: I18n.t('show_type', type: I18n.t('users.type')), href: user_url(user), image: 'fa-user'
        ),
        menu_item(
          :profile, label: I18n.t('profiles.edit.title'), href: edit_profile_link, image: 'fa-pencil'
        )
      ]
    else
      [menu_item(:setup, label: I18n.t('profiles.setup.link'), href: setup_users_url, image: 'fa-user')]
    end
  end

  def user_drafts_item
    menu_item(
      :drafts, label: I18n.t('users.drafts.title'), href: drafts_user_url(resource), image: 'fa-pencil-square-o'
    )
  end

  def user_forum_management_item
    menu_item(:forums, label: I18n.t('forums.management.title'), href: forums_user_url(resource), image: 'fa-group')
  end

  def user_menu_items # rubocop:disable Metrics/AbcSize
    items = user_base_items
    items << user_settings_item
    items << user_drafts_item
    items << user_pages_item
    items << user_forum_management_item if !user_context.vnext && resource.forum_management?
    items << user_notifications_item
    items << sign_out_menu_item
    items
  end

  def user_notifications_item
    unread_count = user.notifications.where(read_at: nil).count
    menu_item(
      :notifications,
      label: "#{I18n.t('users.settings.menu.notifications')}#{unread_count.positive? ? " (#{unread_count})" : ''}",
      href: collection_iri(nil, :notifications),
      image: 'fa-bell'
    )
  end

  def user_pages_item
    menu_item(:pages, label: I18n.t('pages.my_pages'), href: pages_user_url(resource), image: 'fa-building')
  end

  def user_settings_item
    menu_item(
      :settings,
      label: I18n.t('users.settings.title'),
      href: settings_user_users_url,
      image: 'fa-gear'
    )
  end
end
