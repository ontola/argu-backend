# frozen_string_literal: true

class CouponBadgeForm < ApplicationForm
  field :display_name, path: NS::SCHEMA[:name]
  field :coupon_count, path: NS::ARGU[:couponCount], datatype: NS::XSD.integer
end
