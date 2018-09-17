# frozen_string_literal: true

module Users
  class PasswordSerializer < BaseSerializer
    attribute :email, predicate: NS::SCHEMA[:email], datatype: NS::XSD[:string]
  end
end
