# frozen_string_literal: true

class AppMenuList < ApplicationMenuList # rubocop:disable Metrics/ClassLength
  include SettingsHelper
  include LanguageHelper

  has_menu :info,
           label: translations(-> { I18n.t('about.info') }),
           image: 'fa-info',
           link_opts: -> { {triggerClass: 'navbar-item', defaultAction: RDF::URI(i_about_url)} },
           menus: -> { info_menu_items }
  has_menu :user,
           label: -> { resource.display_name },
           image: -> { resource.profile.default_profile_photo.thumbnail },
           link_opts: -> { {triggerClass: 'navbar-item', defaultAction: user_url(user)} },
           menus: -> { user_menu_items }

  def iri_opts
    {parent_iri: 'apex'}
  end

  def iri_template
    uri_template('menu_lists_iri')
  end

  private

  def info_menu_items
    return old_info_menu_items if RequestStore.store[:old_frontend]
    [
      *custom_menu_items(:info, ActsAsTenant.current_tenant),
      menu_item(:powered_by, label: I18n.t('about.powered_by'), href: RDF::URI('https://ontola.io/nl/webdevelopment'))
    ]
  end

  def old_info_menu_items # rubocop:disable Metrics/AbcSize
    [
      menu_item(:about, label: I18n.t('about.about'), href: RDF::URI(i_about_url)),
      menu_item(:team, label: I18n.t('about.team'), href: RDF::URI(info_url(:team))),
      menu_item(:blog, label: I18n.t('about.blog'), href: RDF::URI('https://argu.co/argu/blog/posts')),
      menu_item(:governments, label: I18n.t('about.governments'), href: RDF::URI(info_url(:governments))),
      menu_item(:press_media, label: I18n.t('press_media'), href: RDF::URI('https://argu.pr.co')),
      menu_item(:support, label: I18n.t('help_support'), href: RDF::URI('https://argu.freshdesk.com/support/home')),
      afe_request? ? menu_item(:discover, label: I18n.t('pages.discover'), href: collection_iri(nil, :pages)) : nil,
      menu_item(:contact, label: I18n.t('about.contact'), href: RDF::URI(info_url(:contact)))
    ]
  end

  def edit_profile_link
    afe_request? ? "#{settings_user_users_url}#profile" : settings_user_users_url(tab: :profile)
  end

  def language_menu_item
    menu_item(
      :language,
      label: I18n.t('set_language'),
      href: iri_from_template(:languages_iri)
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
    menu_item(
      :signout,
      action: NS::ONTOLA['actions/logout'],
      label: I18n.t('sign_out'),
      href: destroy_user_session_url
    )
  end

  def user_base_items
    if resource.url.present?
      [
        menu_item(
          :show, label: I18n.t('show_type', type: I18n.t('users.type')), href: user_url(user)
        ),
        menu_item(
          :profile, label: I18n.t('profiles.edit.title'), href: edit_profile_link
        )
      ]
    else
      [menu_item(:setup, label: I18n.t('profiles.setup.link'), href: setup_users_url)]
    end
  end

  def user_forum_management_item
    menu_item(:forums, label: I18n.t('forums.management.title'), href: forums_user_url(resource))
  end

  def user_menu_items # rubocop:disable Metrics/AbcSize
    return [language_menu_item] if resource.guest?

    items = user_base_items
    items << user_settings_item
    items << user_pages_item if Apartment::Tenant.current == 'argu'
    items << user_forum_management_item if !user_context.vnext && resource.forum_management?
    items << language_menu_item if afe_request?
    items << sign_out_menu_item
    items
  end

  def user_pages_item
    menu_item(:pages, label: I18n.t('pages.my_pages'), href: pages_user_url(resource))
  end

  def user_settings_item
    menu_item(
      :settings,
      label: I18n.t('users.settings.title'),
      href: settings_user_users_url
    )
  end
end
