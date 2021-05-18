# frozen_string_literal: true

class CartDetailsController < EdgeableController
  include LinkedRails::Enhancements::Destroyable::Controller

  private

  def collection_action?
    super || %w[delete destroy].include?(action_name)
  end

  def create_success_message; end

  def destroy_success_message; end

  def collection_view_includes(member_includes = {})
    {member_sequence: {members: member_includes}}
  end

  def new_resource_from_params
    return super unless parent_resource!.is_a?(Cart)

    controller_class.new(parent: parent_resource!.parent)
  end

  def parent_resource
    return super unless super.is_a?(BudgetShop)

    @parent_resource = super.cart_for(current_user)
  end

  def permit_params
    {}
  end

  def resource_new_params
    super.merge(shop_id: parent_resource.parent.id)
  end

  def requested_resource
    parent_from_params.try(:cart_detail_for, current_user)
  end
end
