# frozen_string_literal: true

module Couponable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :coupon_badges, predicate: NS::ARGU[:couponBadges]
    end
  end
end
