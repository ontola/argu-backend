# frozen_string_literal: true

module Users
  class UnlockSerializer < BaseSerializer
    attribute :email, predicate: NS::SCHEMA[:email], datatype: NS::XSD[:string]
  end
end
