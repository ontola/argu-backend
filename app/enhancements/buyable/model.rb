# frozen_string_literal: true

module Buyable
  module Model
    extend ActiveSupport::Concern

    included do
      property :price, :integer, NS::SCHEMA.price
      property :product_id, :linked_edge_id, NS::SCHEMA.itemOffered
      validates :price, presence: true
      validates :product_id, presence: true
    end
  end
end
