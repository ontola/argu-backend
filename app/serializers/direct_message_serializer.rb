# frozen_string_literal: true

class DirectMessageSerializer < BaseSerializer
  attribute :subject, predicate: NS::SCHEMA[:name], datatype: NS::XSD[:string]
  attribute :body, predicate: NS::SCHEMA[:text], datatype: NS::XSD[:string]
  attribute :email, predicate: NS::SCHEMA[:email], datatype: NS::XSD[:string]
  attribute :actor, predicate: NS::SCHEMA[:creator], datatype: NS::XSD[:string]
end
