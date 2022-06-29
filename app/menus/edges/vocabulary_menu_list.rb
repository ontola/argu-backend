# frozen_string_literal: true

class VocabularyMenuList < ApplicationMenuList
  has_action_menu
  has_tabs_menu

  private

  def action_menu_items
    [
      edit_link,
      copy_share_link(resource.iri),
      *trash_and_destroy_links(include_destroy: false)
    ]
  end

  def tabs_menu_items
    [
      terms_link
    ]
  end

  def terms_link
    menu_item(
      :terms,
      image: 'fa-list',
      href: resource.collection_iri(:terms)
    )
  end
end
