# frozen_string_literal: true

class CommentMenuList < ApplicationMenuList
  include SettingsHelper

  has_action_menu
  has_follow_menu follow_types: %i[reactions never]

  private

  def action_menu_items
    [edit_link, copy_share_link(resource.iri), *trash_and_destroy_links]
  end
end
