# frozen_string_literal: true

class CategoryForm < ApplicationForm
  fields(
    [
      :display_name,
      {description: {datatype: NS::FHIR[:markdown]}}
    ]
  )
end
