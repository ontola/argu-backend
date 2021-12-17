# frozen_string_literal: true

class BlogPostMenuList < ApplicationMenuList
  include SettingsHelper

  has_action_menu
  has_share_menu

  private

  def action_menu_items
    [edit_link, copy_share_link(resource.iri), *trash_and_destroy_links]
  end
end
