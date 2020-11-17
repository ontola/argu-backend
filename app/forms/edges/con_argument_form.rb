# frozen_string_literal: true

class ConArgumentForm < ApplicationForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]

  footer do
    actor_selector
  end
end
