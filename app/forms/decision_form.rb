# frozen_string_literal: true

class DecisionForm < ApplicationForm
  fields [
    {
      state: {
        sh_in: lambda do
          self.class.form_options(
            'state',
            DecisionSerializer.default_enum_opts('state', %w[rejected approved])
          )
        end
      }
    },
    :description,
    :footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   creator: actor_selector
                 ]
end
