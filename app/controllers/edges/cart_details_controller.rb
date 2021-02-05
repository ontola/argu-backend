# frozen_string_literal: true

class CartDetailsController < EdgeableController
  include LinkedRails::Enhancements::Destroyable::Controller

  private

  def collection_action?
    super || %w[delete destroy].include?(action_name)
  end

  def create_success_message; end

  def destroy_success_message; end

  def permit_params
    {}
  end

  def resource_new_params
    super.merge(shop_id: parent_resource.parent.id)
  end

  def requested_resource
    parent_resource.cart_detail_for(current_user)
  end
end
