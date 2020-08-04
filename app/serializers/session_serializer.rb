# frozen_string_literal: true

class SessionSerializer < BaseSerializer
  attribute :email, predicate: NS::SCHEMA.email, datatype: NS::XSD[:string]
  attribute :r, predicate: NS::ONTOLA[:redirectUrl], datatype: NS::XSD[:string]
end
