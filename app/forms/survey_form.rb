# frozen_string_literal: true

class SurveyForm < ContainerNodeForm
  fields %i[
    display_name
    description
    external_iri
    default_cover_photo
    custom_placement
  ]
end
