# frozen_string_literal: true

module Buyable
  module Serializer
    extend ActiveSupport::Concern

    included do
      money_attribute :price, predicate: NS.argu[:price]
      attribute :currency, predicate: NS.schema.priceCurrency
    end
  end
end
