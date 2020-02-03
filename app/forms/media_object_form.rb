# frozen_string_literal: true

class MediaObjectForm < ApplicationForm
  fields %i[
    content
    remote_content_url
    hidden
  ]

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    order: 98,
    properties: [content_type: {sh_in: -> { target.allowed_content_types }}]
  )
end
