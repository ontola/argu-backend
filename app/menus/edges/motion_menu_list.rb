# frozen_string_literal: true

class MotionMenuList < ApplicationMenuList
  include SettingsHelper
  has_action_menu
  has_follow_menu
  has_share_menu
  has_tabs_menu

  private

  def action_menu_items # rubocop:disable Metrics/MethodLength
    [
      search_link,
      new_update_link,
      convert_link,
      move_link,
      statistics_link,
      permissions_link,
      export_link,
      contact_link,
      transfer_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links
    ]
  end

  def arguments_link
    menu_item(
      :arguments,
      label: Argument.plural_label,
      href: resource.argument_columns_iri
    )
  end

  def tabs_menu_items
    [
      arguments_link,
      comments_link,
      edit_link,
      activity_link
    ]
  end
end
