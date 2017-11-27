# frozen_string_literal: true

class ApplicationMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i[organizations info]

  def iri
    RDF::IRI.new expand_uri_template('menus_iri')
  end

  def info_menu
    menu_item(
      :info,
      label: I18n.t('about.info'),
      image: 'fa-info',
      link_opts: {triggerClass: 'navbar-item', defaultAction: i_about_url},
      menus: [
        menu_item(:about, label: I18n.t('about.about'), href: i_about_url),
        menu_item(:team, label: I18n.t('about.team'), href: info_url(:team)),
        menu_item(:governments, label: I18n.t('about.governments'), href: info_url(:governments)),
        menu_item(:press_media, label: I18n.t('press_media'), href: 'https://argu.pr.co'),
        menu_item(:support, label: I18n.t('help_support'), href: 'https://argu.freshdesk.com/support/home'),
        menu_item(:contact, label: I18n.t('about.contact'), href: info_url(:contact))
      ],
      type: NS::ARGU[:MenuItem]
    )
  end

  private

  def discover_link
    menu_item(
      :discover,
      image: 'fa-compass',
      label: I18n.t('forums.discover'),
      href: discover_forums_url
    )
  end

  def organizations_menu
    menu_item(:organizations, image: 'fa-comments', menus: page_links.append(discover_link))
  end

  def page_links
    pages =
      if user.guest?
        Page
          .joins(forums: :shortname)
          .where(shortnames: {shortname: Setting.get('suggested_forums')&.split(',')&.map(&:strip)})
          .includes(:shortname, profile: :default_profile_photo)
      else
        Page
          .joins(forums: {edge: :favorites})
          .where(favorites: {user_id: user.id})
          .includes(:shortname, profile: :default_profile_photo)
      end
    policy_scope(pages)
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
end
