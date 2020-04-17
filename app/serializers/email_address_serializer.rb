# frozen_string_literal: true

class EmailAddressSerializer < BaseSerializer
  attribute :email, predicate: NS::SCHEMA[:email]
  attribute :primary, predicate: NS::ARGU[:primaryEmail]
  attribute :confirmed_at, predicate: NS::ARGU[:confirmedAt]
  attribute :confirmed?, predicate: NS::ARGU[:confirmed]

  has_one :user, predicate: NS::SCHEMA[:creator]

  delegate :primary, to: :object
end
