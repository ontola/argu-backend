# frozen_string_literal: true

class ScenarioForm < ApplicationForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]
  has_many :attachments
end
