# frozen_string_literal: true

class ProArgumentForm < RailsLD::Form
  fields %i[
    display_name
    description
    footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   creator: actor_selector
                 ]
end
