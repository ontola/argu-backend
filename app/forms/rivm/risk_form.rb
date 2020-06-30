# frozen_string_literal: true

class RiskForm < ApplicationForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]
  field :url
  has_many :attachments
end
