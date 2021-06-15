# frozen_string_literal: true

module CouponBatchable
  module Routing; end

  class << self
    def dependent_classes
      [CouponBatch]
    end

    def route_concerns(mapper)
      mapper.concern :coupon_batchable do
        mapper.resources :coupon_batches, only: %i[index new create]
      end
    end
  end
end
