# frozen_string_literal: true

class DirectMessageSerializer < BaseSerializer
  attribute :subject, predicate: NS.schema.name, datatype: NS.xsd.string
  attribute :body, predicate: NS.schema.text, datatype: NS.xsd.string
  attribute :email_address_id, predicate: NS.schema.email, datatype: NS.xsd.string
  attribute :actor, predicate: NS.schema.creator, datatype: NS.xsd.string
end
