# frozen_string_literal: true

class OrderSerializer < EdgeSerializer
  attribute :coupon, predicate: NS::ARGU[:coupon], if: method(:never)
  attribute :cart_iri, predicate: NS::ARGU[:cart] do |object|
    Cart.new(shop: object.parent).iri
  end
  with_collection :order_details, predicate: NS::ARGU[:orderDetails]
  money_attribute :total_value, predicate: NS::ARGU[:price]
  attribute :currency, predicate: NS::SCHEMA.priceCurrency
end
