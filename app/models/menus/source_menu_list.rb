# frozen_string_literal: true

class SourceMenuList < MenuList
  include SettingsHelper
  cattr_accessor :defined_menus
  has_menus %i[navigations]

  private

  def navigations_menu
    menu_item(
      :navigations,
      menus: [menu_item(:meetings, image: 'fa-calendar-o', href: "#{resource.iri_base}/events")]
    )
  end
end
