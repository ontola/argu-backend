# frozen_string_literal: true

class CreativeWorkForm < ApplicationForm
  visibility_text

  field :display_name
  field :description, datatype: NS.fhir[:markdown]

  footer do
    actor_selector
  end
end
