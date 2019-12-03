# frozen_string_literal: true

class MeasureForm < ApplicationForm
  fields [
    :display_name,
    {description: {datatype: NS::FHIR[:markdown]}},
    {
      parent_id: {
        min_count: 1,
        sh_in: lambda {
          iri_from_template(:measure_types_collection_iri, page: 1, page_size: 100, fragment: :members)
        },
        datatype: NS::XSD[:string],
        input_field: NS::ONTOLA['element/select'],
        default_value: -> { target.parent.is_a?(MeasureType) ? target.parent.iri : nil }
      }
    },
    :comments_allowed,
    :attachments
  ]
end
