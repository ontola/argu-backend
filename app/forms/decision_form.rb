# frozen_string_literal: true

class DecisionForm < ApplicationForm
  fields [
    :state,
    {description: {datatype: NS::FHIR[:markdown]}},
    :footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 order: 99,
                 properties: [
                   creator: actor_selector
                 ]
end
