# frozen_string_literal: true

module Users
  class AuthenticationForm < ApplicationForm
    fields %i[
      url
      password
      password_confirmation
      current_password
    ]
  end
end
