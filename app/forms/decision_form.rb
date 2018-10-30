# frozen_string_literal: true

class DecisionForm < FormsBase
  fields [
    {
      state: {
        sh_in: lambda do |_r|
          form_options(
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
