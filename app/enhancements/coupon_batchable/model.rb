# frozen_string_literal: true

module CouponBatchable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :coupon_batches
    end
  end
end
