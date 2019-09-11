# frozen_string_literal: true

class ProArgumentForm < ApplicationForm
  fields %i[
    display_name
    description
    footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 order: 99,
                 properties: [
                   creator: actor_selector
                 ]
end
