# frozen_string_literal: true

class ApplicationMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i[organizations info user]

  def info_menu
    menu_item(
      :info,
      label: I18n.t('about.info'),
      image: 'fa-info',
      link_opts: {triggerClass: 'navbar-item', defaultAction: i_about_url},
      menus: lambda {
        [
          menu_item(:about, label: I18n.t('about.about'), href: i_about_url),
          menu_item(:team, label: I18n.t('about.team'), href: info_url(:team)),
          menu_item(:governments, label: I18n.t('about.governments'), href: info_url(:governments)),
          menu_item(:press_media, label: I18n.t('press_media'), href: 'https://argu.pr.co'),
          menu_item(:support, label: I18n.t('help_support'), href: 'https://argu.freshdesk.com/support/home'),
          menu_item(:contact, label: I18n.t('about.contact'), href: info_url(:contact))
        ]
      }
    )
  end

  def iri(opts = {})
    RDF::URI(expand_uri_template('menus_iri', opts))
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

  def discover_link
    menu_item(
      :discover,
      image: 'fa-compass',
      label: I18n.t('pages.discover'),
      href: pages_url(page: 1, type: :paginated)
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

  def public_page_links
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

  def user_links
    items =
      if resource.url.present?
        [
          menu_item(
            :show, label: I18n.t('show_type', type: I18n.t('users.type')), href: user_url(user), image: 'fa-user'
          ),
          menu_item(
            :profile, label: I18n.t('profiles.edit.title'), href: settings_user_url(tab: :profile), image: 'fa-pencil'
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
    if resource.forum_management?
      items <<
        menu_item(:forums, label: I18n.t('forums.management.title'), href: forums_user_url(resource), image: 'fa-group')
    end
    items << menu_item(:signout, label: I18n.t('sign_out'), href: destroy_user_session_url, image: 'fa-sign-out')
    items
  end
end
