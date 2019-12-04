# frozen_string_literal: true

module Users
  class AuthenticationForm < ApplicationForm
    fields [
      :url,
      :password,
      :password_confirmation,
      :current_password,
      email_addresses_table: {
        type: :resource,
        url: -> { collection_iri(user_context.user, :email_addresses, display: :settingsTable) }
      }
    ]
  end
end
