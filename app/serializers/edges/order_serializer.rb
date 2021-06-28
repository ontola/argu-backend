# frozen_string_literal: true

class OrderSerializer < EdgeSerializer
  attribute :coupon, predicate: NS.argu[:coupon], if: method(:never)
  attribute :cart_iri, predicate: NS.argu[:cart] do |object|
    Cart.new(shop: object.parent).iri
  end
  with_collection :order_details, predicate: NS.argu[:orderDetails]
  money_attribute :total_value, predicate: NS.argu[:price]
  attribute :currency, predicate: NS.schema.priceCurrency
end
