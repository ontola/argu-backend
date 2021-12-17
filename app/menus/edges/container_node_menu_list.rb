# frozen_string_literal: true

class ContainerNodeMenuList < ApplicationMenuList
  include SettingsHelper

  private

  def action_menu_items
    [
      activity_link,
      search_link,
      statistics_link,
      export_link,
      widgets_link,
      copy_share_link(resource.iri),
      destroy_link,
      edit_link
    ]
  end

  def edit_link
    menu_item(
      :edit,
      dialog: true,
      image: 'fa-gear',
      label: I18n.t('menus.default.settings'),
      href: edit_iri(resource),
      policy: :update?
    )
  end
end
