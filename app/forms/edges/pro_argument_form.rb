# frozen_string_literal: true

class ProArgumentForm < ApplicationForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]

  footer do
    actor_selector
  end
end
