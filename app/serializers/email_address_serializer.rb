# frozen_string_literal: true

class EmailAddressSerializer < BaseSerializer
  attribute :email, predicate: NS.schema.email
  attribute :primary, predicate: NS.argu[:primaryEmail]
  attribute :confirmed_at, predicate: NS.argu[:confirmedAt]
  attribute :confirmed?, predicate: NS.argu[:confirmed]

  has_one :user, predicate: NS.schema.creator

  delegate :primary, to: :object
end
