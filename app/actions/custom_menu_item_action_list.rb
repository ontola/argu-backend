# frozen_string_literal: true

class CustomMenuItemActionList < ApplicationActionList
  has_resource_update_action(
    description: lambda {
      resource.edge_id.present? ? I18n.t('custom_menu_items.form.coupled_to', name: resource.edge.display_name) : nil
    }
  )
end
