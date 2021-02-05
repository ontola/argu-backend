# frozen_string_literal: true

class CartSerializer < BaseSerializer
  attribute :budget_max, predicate: NS::ARGU[:budgetMax]
  attribute :total_value, predicate: NS::SCHEMA.totalPaymentDue
  attribute :currency, predicate: NS::SCHEMA.priceCurrency
end
