# frozen_string_literal: true

class PageForm < ApplicationForm
  fields [
    :name,
    :about,
    :url,
    {
      primary_container_node_id: {
        datatype: NS::XSD[:string],
        max_count: 1,
        sh_in: -> { target.container_nodes.map(&:iri) }
      }
    },
    :last_accepted,
    :theme,
    delete_button: {
      type: :resource,
      url: -> { delete_iri(target) }
    }
  ]

  property_group :theme,
                 label: -> { I18n.t('forms.theme.label') },
                 description: -> { I18n.t('forms.theme.description') },
                 properties: %i[
                   navbar_color
                   navbar_background
                   accent_color
                   accent_background_color
                 ]
end
