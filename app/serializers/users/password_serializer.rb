# frozen_string_literal: true

module Users
  class PasswordSerializer < BaseSerializer
    attribute :email, predicate: NS::SCHEMA[:email], datatype: NS::XSD[:string]
    attribute :password, predicate: NS::ONTOLA[:password], datatype: NS::ONTOLA['datatype/password'], if: method(:never)
    attribute :password_confirmation,
              predicate: NS::ONTOLA[:passwordConfirmation],
              datatype: NS::ONTOLA['datatype/password'],
              if: method(:never)
    attribute :reset_password_token, predicate: NS::ARGU[:resetPasswordToken], datatype: NS::XSD[:string]
  end
end
