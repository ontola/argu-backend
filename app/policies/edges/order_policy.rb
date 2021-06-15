# frozen_string_literal: true

class OrderPolicy < EdgePolicy
  permit_attributes %i[coupon]

  def show?
    new_record? || is_creator?
  end

  def create?
    cart = record.parent.cart_for(user)

    return forbid_with_message(I18n.t('actions.orders.create.errors.budget_exceeded')) if cart.budget_exceeded?
    return forbid_with_message(I18n.t('actions.orders.create.errors.cart_empty')) if cart.cart_details.empty?

    super
  end
end
