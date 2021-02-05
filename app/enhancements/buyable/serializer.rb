# frozen_string_literal: true

module Buyable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :price, predicate: NS::SCHEMA.price
      attribute :currency, predicate: NS::SCHEMA.priceCurrency
    end
  end
end
