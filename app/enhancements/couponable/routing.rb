# frozen_string_literal: true

module Couponable
  module Routing; end

  class << self
    def dependent_classes
      [CouponBadge]
    end

    def route_concerns(mapper)
      mapper.concern :couponable do
        mapper.resources :coupon_badges, only: %i[index new create]
      end
    end
  end
end
