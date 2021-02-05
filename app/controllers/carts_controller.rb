# frozen_string_literal: true

class CartsController < ParentableController
  private

  def requested_resource
    @requested_resource ||=
      Cart.new(
        shop: parent_resource,
        user: current_user
      )
  end
end
