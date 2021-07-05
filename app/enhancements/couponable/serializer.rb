# frozen_string_literal: true

module Couponable
  module Serializer
    extend ActiveSupport::Concern

    included do
      secret_attribute :coupon, predicate: NS.argu[:coupon]
      attribute :require_coupon, predicate: NS.argu[:requireCoupon]
    end
  end
end
