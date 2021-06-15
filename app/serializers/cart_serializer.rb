# frozen_string_literal: true

class CartSerializer < BaseSerializer
  money_attribute :budget_max, predicate: NS::ARGU[:budgetMax]
  money_attribute :total_value, predicate: NS::SCHEMA.totalPaymentDue
  attribute :currency, predicate: NS::SCHEMA.priceCurrency
  attribute :create_offer_iri, predicate: NS::ARGU[:checkoutAction] do |object|
    object.shop.order_collection.action(:create).iri
  end
  with_collection :cart_details, predicate: NS::ARGU[:cartDetails]
end
