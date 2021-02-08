# frozen_string_literal: true

class Order < Edge
  enhance LinkedRails::Enhancements::Creatable
  parentable :budget_shop
  after_commit :clear_cart!

  def cart
    @cart ||= parent.cart_for(publisher)
  end

  def display_name; end

  def added_delta # rubocop:disable Metrics/AbcSize
    [
      [cart.iri, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)],
      [parent.order_collection.action(:create).iri, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)],
      [NS::SP[:Variable], RDF.type, NS::ONTOLA['Create::CartDetail'], delta_iri(:invalidate)],
      [NS::SP[:Variable], RDF.type, NS::ONTOLA['Destroy::CartDetail'], delta_iri(:invalidate)]
    ]
  end

  private

  def clear_cart!
    cart.cart_details.each(&:destroy)
  end

  def create_as_guest?
    true
  end
end
