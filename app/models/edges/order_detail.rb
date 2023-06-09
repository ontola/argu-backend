# frozen_string_literal: true

class OrderDetail < Edge
  parentable :order
  collection_options(
    display: :table
  )

  property :offer_id, :linked_edge_id, NS.schema.orderedItem, association: :offer, association_class: 'Edge'
  after_create :follow_product
  with_columns default: [
    NS.schema.orderedItem,
    NS.argu[:price]
  ]
  delegate :price, :currency, to: :offer

  private

  def follow_product
    publisher.follow(offer.product, :news, :news)
  end

  class << self
    def iri
      NS.schema.OrderItem
    end
  end
end
