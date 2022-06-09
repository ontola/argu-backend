# frozen_string_literal: true

class QuestionMenuList < ApplicationMenuList
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
      copy_share_link(resource.iri),
      transfer_link,
      *trash_and_destroy_links
    ]
  end

  def motions_link
    menu_item(
      :motions,
      label: Motion.plural_label,
      href: resource.collection_iri(:motions)
    )
  end

  def location_link
    return nil unless resource.map_question? && resource.location_query_iri

    menu_item(
      :location,
      href: resource.location_query_iri
    )
  end

  def tabs_menu_items
    [
      location_link,
      motions_link,
      comments_link,
      edit_link,
      activity_link
    ]
  end
end
