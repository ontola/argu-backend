# frozen_string_literal: true

class AccessTokenForm < ApplicationForm
  field :email, input_field: LinkedRails::Form::Field::EmailInput, min_count: 1
  field :password,
        description: '',
        input_field: LinkedRails::Form::Field::PasswordInput,
        min_count: 1
  hidden do
    field :redirect_url
  end
end
