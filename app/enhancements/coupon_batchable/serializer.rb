# frozen_string_literal: true

module CouponBatchable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :coupon_batches, predicate: NS.argu[:couponBatches]
    end
  end
end
