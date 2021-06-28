# frozen_string_literal: true

class CouponBatchForm < ApplicationForm
  field :display_name, path: NS.schema.name
  field :coupon_count, path: NS.argu[:couponCount], datatype: NS.xsd.integer
end
