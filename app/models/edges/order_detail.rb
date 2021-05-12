# frozen_string_literal: true

class OrderDetail < Edge
  parentable :order

  property :offer_id, :linked_edge_id, NS::SCHEMA.orderedItem
  belongs_to :offer, foreign_key_property: :offer_id, class_name: 'Edge', dependent: false
  after_create :follow_product

  def display_name; end

  private

  def follow_product
    publisher.follow(offer.product, :news, :news)
  end

  class << self
    def iri
      NS::SCHEMA.OrderItem
    end
  end
end
