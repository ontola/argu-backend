# frozen_string_literal: true

class ApplicationMenuList < MenuList # rubocop:disable Metrics/ClassLength
  include SettingsHelper
  include LanguageHelper
  cattr_accessor :defined_menus
  has_menus %i[organizations info user]

  def info_menu # rubocop:disable Metrics/AbcSize
    menu_item(
      :info,
      label: I18n.t('about.info'),
      image: 'fa-info',
      link_opts: {triggerClass: 'navbar-item', defaultAction: RDF::URI(i_about_url)},
      menus: lambda {
        [
          menu_item(:about, label: I18n.t('about.about'), href: RDF::URI(i_about_url)),
          menu_item(:team, label: I18n.t('about.team'), href: RDF::URI(info_url(:team))),
          menu_item(:blog, label: I18n.t('about.blog'), href: collection_iri('/argu', :blog_posts)),
          menu_item(:governments, label: I18n.t('about.governments'), href: RDF::URI(info_url(:governments))),
          menu_item(:press_media, label: I18n.t('press_media'), href: RDF::URI('https://argu.pr.co')),
          menu_item(:support, label: I18n.t('help_support'), href: RDF::URI('https://argu.freshdesk.com/support/home')),
          menu_item(:contact, label: I18n.t('about.contact'), href: RDF::URI(info_url(:contact))),
          menu_item(
            :language,
            label: I18n.t('set_language'),
            href: RDF::DynamicURI(expand_uri_template(:languages_iri, with_hostname: true))
          )
        ]
      }
    )
  end

  def iri_path(opts = {})
    expand_uri_template('menus_iri', opts)
  end

  def user_menu
    return [] if user.guest?
    menu_item(
      :user,
      label: resource.display_name,
      image: resource.profile.default_profile_photo.thumbnail,
      link_opts: {triggerClass: 'navbar-item', defaultAction: user_url(user)},
      menus: -> { user_links }
    )
  end

  private

  def edit_profile_link
    afe_request? ? "#{settings_user_url}#profile" : settings_user_url(tab: :profile)
  end

  def discover_link
    menu_item(
      :discover,
      image: 'fa-compass',
      label: I18n.t('pages.discover'),
      href: pages_url
    )
  end

  def favorite_pages
    return Page.none if user.guest?
    return @favorite_pages if instance_variable_defined?('@favorite_pages')
    page_ids =
      Forum.joins(:favorites, :parent).where(favorites: {user_id: user.id}).pluck('parents_edges.uuid')
    @favorite_pages ||=
      Page.where(uuid: page_ids).includes(:shortname, profile: :default_profile_photo)
  end

  def favorite_page_links
    return if favorite_pages.blank?
    policy_scope(favorite_pages)
      .distinct
      .map do |page|
      menu_item(
        page.url,
        image: page.profile.try(:default_profile_photo),
        label: page.display_name,
        href: page.iri
      )
    end
  end

  def organizations_menu
    menu_item(
      :organizations,
      image: 'fa-comments',
      menus: -> { [favorite_page_links, public_page_links, discover_link].flatten }
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

  def public_page_links # rubocop:disable Metrics/AbcSize
    return if favorite_pages.count > 20 || public_pages.blank?
    menu_items = lambda {
      (policy_scope(public_pages) - favorite_pages)
        .uniq
        .map do |page|
        menu_item(
          page.url,
          image: page.profile.try(:default_profile_photo),
          label: page.display_name,
          href: page.iri
        )
      end
    }
    return menu_items.call if favorite_pages.count.zero?
    menu_item(
      :public_pages,
      label: I18n.t('pages.discover_header'),
      type: NS::ARGU[:MenuSection],
      menus: menu_items
    )
  end

  def sign_out_menu_item
    menu_item(:signout,
              action: NS::ONTOLA['actions/logout'],
              label: I18n.t('sign_out'),
              href: destroy_user_session_url,
              image: 'fa-sign-out')
  end

  def user_links # rubocop:disable Metrics/AbcSize
    items =
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
    items << menu_item(:settings, label: I18n.t('users.settings.title'), href: settings_user_url, image: 'fa-gear')
    items << menu_item(
      :drafts, label: I18n.t('users.drafts.title'), href: drafts_user_url(resource), image: 'fa-pencil-square-o'
    )
    items <<
      if resource.page_management?
        menu_item(:pages, label: I18n.t('pages.management.title'), href: pages_user_url(resource), image: 'fa-building')
      else
        menu_item(:create_page, label: I18n.t('pages.create'), href: new_page_url, image: 'fa-building')
      end
    if !user_context.vnext && resource.forum_management?
      items <<
        menu_item(:forums, label: I18n.t('forums.management.title'), href: forums_user_url(resource), image: 'fa-group')
    end
    items << sign_out_menu_item
    items
  end
end
