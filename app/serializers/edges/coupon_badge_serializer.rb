# frozen_string_literal: true

class CouponBadgeSerializer < EdgeSerializer
  attribute :coupon_count, predicate: NS::ARGU[:couponCount]
  attribute :coupons, predicate: NS::ARGU[:coupons]
end
