# frozen_string_literal: true

class OrderForm < ApplicationForm
  resource :cart, path: NS.argu[:cart]
  field :coupon
end
