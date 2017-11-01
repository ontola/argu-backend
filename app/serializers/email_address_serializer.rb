# frozen_string_literal: true

class EmailAddressSerializer < BaseSerializer
  attribute :email, predicate: RDF::SCHEMA[:email]
  attribute :primary
  attribute :confirmed_at

  has_one :user, predicate: RDF::SCHEMA[:creator]
end
