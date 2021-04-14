# frozen_string_literal: true

module Buyable
  module Model
    extend ActiveSupport::Concern

    included do
      property :price, :integer, NS::ARGU[:price]
      property :product_id, :linked_edge_id, NS::SCHEMA.itemOffered
      validates :price, presence: true
      validates :product_id, presence: true

      with_collection :cart_details

      def price
        Money.new(super, currency) if super
      end
    end
  end
end
