# frozen_string_literal: true

class ContainerNodeMenuList < ApplicationMenuList
  include SettingsHelper

  private

  def action_menu_items # rubocop:disable Metrics/MethodLength
    [
      activity_link,
      search_link,
      statistics_link,
      export_link,
      widgets_link,
      permissions_link,
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

  def tabs_menu_items
    [
      dashboard_link,
      widgets_link
    ]
  end

  def dashboard_link
    menu_item(
      :dashboard,
      label: I18n.t('argu.Dashboard.label'),
      href: resource.iri
    )
  end
end
