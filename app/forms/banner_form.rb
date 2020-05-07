# frozen_string_literal: true

class BannerForm < ApplicationForm
  fields(
    [
      {description: {datatype: NS::FHIR[:markdown]}},
      :audience,
      :dismiss_button,
      :expires_at,
      :hidden,
      :footer
    ]
  )

  property_group(
    :footer,
    iri: NS::ONTOLA[:footerGroup],
    order: 99,
    properties: [
      creator: actor_selector
    ]
  )

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    order: 98,
    properties: %i[argu_publication]
  )
end
