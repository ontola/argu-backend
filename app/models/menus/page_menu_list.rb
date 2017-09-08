# frozen_string_literal: true

class PageMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i[navigations]

  private

  def navigations_menu
    menu_item(
      :navigations,
      menus: policy_scope(resource.forums)
               .map { |forum| navigation_item(forum) }
               .concat(resource.sources.map { |source| navigation_item(source) })
    )
  end

  def navigation_item(record)
    menu_item(
      record.url.to_sym,
      href: record.context_id,
      label: record.display_name,
      menus: record.menu(user_context, :navigations).menus,
      image: record.try(:default_profile_photo),
      policy: :show?,
      policy_resource: record
    )
  end
end
