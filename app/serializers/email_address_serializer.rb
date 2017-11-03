# frozen_string_literal: true

class EmailAddressSerializer < BaseSerializer
  attribute :email, predicate: NS::SCHEMA[:email]
  attribute :primary
  attribute :confirmed_at

  has_one :user, predicate: NS::SCHEMA[:creator]
end
