# frozen_string_literal: true

class OrderDetailSerializer < EdgeSerializer
  money_attribute :price, predicate: NS::ARGU[:price]
  attribute :currency, predicate: NS::SCHEMA.priceCurrency
  has_one :offer, predicate: NS::SCHEMA.orderedItem
end
