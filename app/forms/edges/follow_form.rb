# frozen_string_literal: true

class FollowForm < ApplicationForm
  field :follow_type,
        label: '',
        input_field: LinkedRails::Form::Field::RadioGroup
end
