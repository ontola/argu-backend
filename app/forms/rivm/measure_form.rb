# frozen_string_literal: true

class MeasureForm < ApplicationForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]
  field :parent_id,
        min_count: 1,
        sh_in: lambda {
          iri_from_template(:measure_types_collection_iri, page: 1, page_size: 100, fragment: :members)
        },
        datatype: NS::XSD[:string],
        input_field: LinkedRails::Form::Field::SelectInput
  field :comments_allowed
  has_many :attachments

  hidden do
    field :is_draft
  end
end
