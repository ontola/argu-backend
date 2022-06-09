# frozen_string_literal: true

class BlogPostMenuList < ApplicationMenuList
  include SettingsHelper

  has_action_menu
  has_share_menu
  has_tabs_menu

  private

  def action_menu_items
    [
      edit_link,
      permissions_link,
      copy_share_link(resource.iri),
      transfer_link,
      *trash_and_destroy_links
    ]
  end

  def tabs_menu_items
    [
      comments_link,
      edit_link
    ]
  end
end
