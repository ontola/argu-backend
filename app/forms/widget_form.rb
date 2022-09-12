# frozen_string_literal: true

class WidgetForm < ApplicationForm
  field :raw_resource_iri,
        min_count: 1,
        max_length: 5000
  field :view,
        min_count: 1
  field :size,
        min_count: 1,
        input_field: LinkedRails::Form::Field::NumberInput,
        max_inclusive: 3,
        min_inclusive: 1
end
