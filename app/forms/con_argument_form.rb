# frozen_string_literal: true

class ConArgumentForm < FormsBase
  fields %i[
    display_name
    description
    footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: %i[
                   creator
                 ]
end
