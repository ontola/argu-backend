# frozen_string_literal: true

module Users
  class UnlockForm < ApplicationForm
    field :email, input_field: LinkedRails::Form::Field::EmailInput, min_count: 1
  end
end
