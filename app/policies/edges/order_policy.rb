# frozen_string_literal: true

class OrderPolicy < EdgePolicy
  def show?
    is_creator?
  end

  def create? # rubocop:disable Metrics/AbcSize
    cart = record.parent.cart_for(user)

    return forbid_with_message(I18n.t('actions.orders.create.errors.submitted')) if cart.submitted?
    return forbid_with_message(I18n.t('actions.orders.create.errors.budget_exceeded')) if cart.budget_exceeded?
    return forbid_with_message(I18n.t('actions.orders.create.errors.cart_empty')) if cart.cart_details.empty?

    super
  end
end
