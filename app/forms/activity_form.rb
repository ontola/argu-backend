# frozen_string_literal: true

class ActivityForm < ApplicationForm
  field :comment,
        input_field: LinkedRails::Form::Field::TextAreaInput,
        label: ''
  field :notify
end
