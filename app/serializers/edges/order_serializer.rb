# frozen_string_literal: true

class OrderSerializer < EdgeSerializer
  attribute :cart_iri, predicate: NS::ARGU[:cart] do |object|
    Cart.new(shop: object.parent).iri
  end
  attribute :coupon, predicate: NS::ARGU[:coupon]
end
