# frozen_string_literal: true

class OrdersController < EdgeableController
  private

  def create_success_message
    I18n.t('actions.orders.create.success')
  end

  def redirect_location
    current_resource.parent.iri
  end
end
