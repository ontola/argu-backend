# frozen_string_literal: true

module Users
  class PasswordForm < FormsBase
    fields %i[email password password_confirmation hidden]
    property_group :hidden, label: 'hidden', properties: %i[reset_password_token], iri: NS::ONTOLA[:hiddenGroup]
  end
end
