# frozen_string_literal: true

module Buyable
  module Serializer
    extend ActiveSupport::Concern

    included do
      money_attribute :price, predicate: NS::ARGU[:price]
      attribute :currency, predicate: NS::SCHEMA.priceCurrency
    end
  end
end
