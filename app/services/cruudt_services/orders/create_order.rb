# frozen_string_literal: true

class CreateOrder < CreateEdge
  private

  def assign_attributes
    super
    resource.cart.cart_details.each do |cart_detail|
      resource.order_details.build(
        active_branch: resource.active_branch,
        is_published: true,
        creator: creator,
        publisher: publisher,
        offer: cart_detail.parent
      )
    end
  end
end
