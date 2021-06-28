# frozen_string_literal: true

class OrderDetailSerializer < EdgeSerializer
  money_attribute :price, predicate: NS.argu[:price]
  attribute :currency, predicate: NS.schema.priceCurrency
  has_one :offer, predicate: NS.schema.orderedItem
end
