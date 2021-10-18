# frozen_string_literal: true

class Order < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance Couponable
  parentable :budget_shop
  after_commit :clear_cart!
  collection_options(
    display: :table
  )
  delegate :currency, to: :parent
  attr_accessor :cart

  with_collection :order_details
  with_columns default: [
    NS.schema.creator,
    NS.argu[:orderDetails],
    NS.argu[:price],
    NS.schema.dateCreated
  ]

  def added_delta # rubocop:disable Metrics/AbcSize
    [
      [cart.iri, NS.sp.Variable, NS.sp.Variable, delta_iri(:invalidate)],
      [parent.order_collection.action(:create).iri, NS.sp.Variable, NS.sp.Variable, delta_iri(:invalidate)],
      [NS.sp.Variable, RDF.type, NS.ontola['Create::CartDetail'], delta_iri(:invalidate)],
      [NS.sp.Variable, RDF.type, NS.ontola['Destroy::CartDetail'], delta_iri(:invalidate)]
    ]
  end

  def display_name
    Order.label
  end

  def total_value
    @total_value ||= Money.new(order_details_values.sum, currency)
  end

  private

  def clear_cart!
    cart.cart_details.each(&:destroy)
  end

  def order_details_values
    order_details.map { |detail| detail.offer.price }
  end

  class << self
    def attributes_for_new(opts)
      super.merge(
        cart: opts[:parent]&.cart_for(opts[:user_context])
      )
    end

    def interact_as_guest?
      true
    end
  end
end
