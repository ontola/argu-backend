# frozen_string_literal: true

class ImageObjectForm < ApplicationForm
  fields %i[
    content
    hidden
  ]

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    order: 98,
    properties: [
      {content_type: {sh_in: -> { target.allowed_content_types }}},
      {position_y: {default_value: 50}}
    ]
  )
end
