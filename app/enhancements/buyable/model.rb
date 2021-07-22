# frozen_string_literal: true

module Buyable
  module Model
    extend ActiveSupport::Concern

    included do
      property :price, :integer, NS.argu[:price]
      property :product_id, :linked_edge_id, NS.schema.itemOffered, association_class: 'Edge'

      validates :price, presence: true
      validates :product_id, presence: true

      with_collection :cart_details

      delegate :currency, to: :parent

      def price
        Money.new(super, currency) if super
      end
    end
  end
end
