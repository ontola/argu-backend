# frozen_string_literal: true

class ProArgumentForm < ApplicationForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]

  footer do
    actor_selector
  end
end
