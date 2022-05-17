# frozen_string_literal: true

class PropertyDefinitionMenuList < ApplicationMenuList
  has_menu(
    :actions,
    image: 'fa-ellipsis-v',
    menus: -> { action_menu_items }
  )

  private

  def action_menu_items
    [
      copy_share_link(resource.iri),
      edit_link,
      destroy_link
    ]
  end
end
