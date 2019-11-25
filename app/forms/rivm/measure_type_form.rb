# frozen_string_literal: true

class MeasureTypeForm < ApplicationForm
  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    {
      example_of_id: {
        max_count: 99,
        sh_in: -> { iri_from_template(:risks_collection_iri, page: 1, page_size: 100, fragment: :members) },
        datatype: NS::XSD[:string],
        default_value: -> { [target.parent&.iri] }
      }
    },
    {
      category_id: {
        sh_in: -> { iri_from_template(:categories_collection_iri, page: 1, page_size: 100, fragment: :members) },
        datatype: NS::XSD[:string],
        default_value: -> { target.parent.is_a?(Category) ? target.parent.iri : target.category&.iri }
      }
    },
    :attachments
  ]
end
