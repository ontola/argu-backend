# frozen_string_literal: true

class OrderForm < ApplicationForm
  resource :cart, path: NS::ARGU[:cart]
  field :coupon
end
