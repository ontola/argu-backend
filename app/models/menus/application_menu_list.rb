# frozen_string_literal: true

class ApplicationMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i[organizations]

  def context_id
    "https://#{Rails.application.config.host_name}/menus"
  end
  alias id context_id

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
        href: page.context_id
      )
    end
  end
end
