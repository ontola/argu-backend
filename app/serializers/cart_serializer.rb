# frozen_string_literal: true

class CartSerializer < BaseSerializer
  money_attribute :budget_max, predicate: NS.argu[:budgetMax]
  money_attribute :total_value, predicate: NS.schema.totalPaymentDue
  attribute :currency, predicate: NS.schema.priceCurrency
  attribute :create_offer_iri, predicate: NS.argu[:checkoutAction] do |object|
    object.shop.order_collection.action(:create).iri
  end
  with_collection :cart_details, predicate: NS.argu[:cartDetails]
end
