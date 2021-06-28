# frozen_string_literal: true

class CustomMenuItemActionList < ApplicationActionList
  has_resource_update_action(
    root_relative_iri: lambda {
      uri = resource.root_relative_iri.dup
      uri.path ||= ''
      uri.path += '/edit'
      uri.to_s
    },
    url: -> { resource.iri },
    description: lambda {
      resource.edge_id.present? ? I18n.t('custom_menu_items.form.coupled_to', name: resource.edge.display_name) : nil
    }
  )
  has_resource_destroy_action(
    root_relative_iri: lambda {
      uri = resource.root_relative_iri.dup
      uri.path ||= ''
      uri.path += '/delete'
      uri.to_s
    },
    url: -> { resource.iri }
  )
end
