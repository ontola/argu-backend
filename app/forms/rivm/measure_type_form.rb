# frozen_string_literal: true

class MeasureTypeForm < ApplicationForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]
  field :example_of_id,
        max_count: 99,
        sh_in: -> { iri_from_template(:risks_collection_iri, page: 1, page_size: 100, fragment: :members) },
        datatype: NS::XSD[:string]
  field :category_id,
        sh_in: -> { iri_from_template(:categories_collection_iri, page: 1, page_size: 100, fragment: :members) },
        datatype: NS::XSD[:string]
  has_many :attachments
end
