# frozen_string_literal: true

class ConArgumentForm < ApplicationForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]

  footer do
    actor_selector
  end
end
