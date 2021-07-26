# frozen_string_literal: true

class InterventionTypeForm < ApplicationForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  has_many :attachments

  footer do
    actor_selector
  end
end
