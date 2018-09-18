# frozen_string_literal: true

module Users
  class ConfirmationSerializer < BaseSerializer
    attribute :email, predicate: NS::SCHEMA[:email], datatype: NS::XSD[:string]
  end
end
