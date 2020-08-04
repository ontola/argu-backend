# frozen_string_literal: true

module Users
  class PasswordForm < ApplicationForm
    field :email, input_field: LinkedRails::Form::Field::EmailInput, min_count: 1
    field :password
    field :password_confirmation

    hidden do
      field :reset_password_token
    end
  end
end
