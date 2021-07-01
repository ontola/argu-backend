# frozen_string_literal: true

module Users
  class AccessTokenForm < LinkedRails::Auth::AccessTokenForm
    field :email,
          input_field: LinkedRails::Form::Field::EmailInput,
          min_count: 1
    field :password,
          description: '',
          input_field: LinkedRails::Form::Field::PasswordInput,
          min_count: 1
    resource :reset_password, url: -> { LinkedRails.iri(path: '/u/password/new') }

    hidden do
      field :redirect_url
    end
  end
end
