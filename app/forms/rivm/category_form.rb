# frozen_string_literal: true

class CategoryForm < ApplicationForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]
end
