# frozen_string_literal: true

class DecisionForm < ApplicationForm
  fields [
    {
      state: {
        sh_in: form_options('state', DecisionSerializer.default_enum_opts('state', %w[approved rejected]))
      }
    },
    :description,
    :footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 order: 99,
                 properties: [
                   creator: actor_selector
                 ]
end
