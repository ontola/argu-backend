# frozen_string_literal: true

class EmailAddressSerializer < BaseSerializer
  attribute :email, predicate: NS::SCHEMA[:email]
  attribute :primary, predicate: NS::ARGU[:primaryEmail]
  attribute :confirmed_at, predicate: NS::ARGU[:confirmedAt]

  has_one :user, predicate: NS::SCHEMA[:creator]

  def updated_at; end

  def primary
    object.primary if object.primary
  end
end
