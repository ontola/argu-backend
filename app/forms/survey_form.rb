# frozen_string_literal: true

class SurveyForm < ContainerNodeForm
  fields %i[
    display_name
    description
    external_iri
    default_cover_photo
    custom_placement
    footer
  ]

  property_group(
    :footer,
    iri: NS::ONTOLA[:footerGroup],
    order: 99,
    properties: [
      creator: actor_selector
    ]
  )
end
