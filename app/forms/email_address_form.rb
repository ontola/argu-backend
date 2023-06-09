# frozen_string_literal: true

class EmailAddressForm < ApplicationForm
  field :email, input_field: LinkedRails::Form::Field::EmailInput, min_count: 1
end
