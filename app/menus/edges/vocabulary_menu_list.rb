# frozen_string_literal: true

class VocabularyMenuList < ApplicationMenuList
  include Helpers::ActionMenuItems

  has_action_menu

  private

  def action_menu_items
    [
      copy_share_link(resource.iri),
      edit_link,
      *trash_and_destroy_links(include_destroy: false)
    ]
  end
end
