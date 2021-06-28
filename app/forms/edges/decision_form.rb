# frozen_string_literal: true

class DecisionForm < ApplicationForm
  field :state, input_field: LinkedRails::Form::Field::RadioGroup
  field :description, datatype: NS.fhir[:markdown]

  footer do
    actor_selector
  end
end
