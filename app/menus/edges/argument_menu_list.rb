# frozen_string_literal: true

class ArgumentMenuList < ApplicationMenuList
  include SettingsHelper

  has_action_menu
  has_follow_menu follow_types: %i[reactions never]
  has_share_menu

  private

  def action_menu_items
    [
      activity_link,
      edit_link,
      copy_share_link(resource.iri),
      transfer_link,
      *trash_and_destroy_links, contact_link
    ]
  end
end
