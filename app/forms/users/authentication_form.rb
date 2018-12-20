# frozen_string_literal: true

module Users
  class AuthenticationForm < RailsLD::Form
    fields %i[
      url
      password
      password_confirmation
      current_password
    ]
  end
end
