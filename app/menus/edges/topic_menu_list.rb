# frozen_string_literal: true

class TopicMenuList < ApplicationMenuList
  include SettingsHelper

  has_action_menu
  has_follow_menu
  has_share_menu

  private

  def action_menu_items # rubocop:disable Metrics/MethodLength
    [
      edit_link,
      activity_link,
      search_link,
      new_update_link,
      convert_link,
      move_link,
      statistics_link,
      permissions_link,
      export_link,
      contact_link,
      copy_share_link(resource.iri),
      transfer_link,
      *trash_and_destroy_links
    ]
  end
end
