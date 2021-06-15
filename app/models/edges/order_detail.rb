# frozen_string_literal: true

class OrderDetail < Edge
  enhance LinkedRails::Enhancements::Tableable

  parentable :order

  property :offer_id, :linked_edge_id, NS::SCHEMA.orderedItem
  belongs_to :offer, foreign_key_property: :offer_id, class_name: 'Edge', dependent: false
  after_create :follow_product
  with_columns default: [
    NS::SCHEMA.orderedItem,
    NS::ARGU[:price]
  ]
  delegate :price, :currency, to: :offer

  private

  def follow_product
    publisher.follow(offer.product, :news, :news)
  end

  class << self
    def default_collection_display
      :table
    end

    def iri
      NS::SCHEMA.OrderItem
    end
  end
end
