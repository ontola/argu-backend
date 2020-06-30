# frozen_string_literal: true

class InterventionTypeForm < ApplicationForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]
  has_many :attachments
end
