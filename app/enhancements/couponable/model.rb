# frozen_string_literal: true

module Couponable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :coupon_badges
    end
  end
end
