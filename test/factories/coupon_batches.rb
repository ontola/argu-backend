# frozen_string_literal: true

FactoryBot.define do
  factory :coupon_batch do
    sequence(:display_name) { |n| "fg coupons #{n}end" }
    coupon_count { 2 }
  end
end
