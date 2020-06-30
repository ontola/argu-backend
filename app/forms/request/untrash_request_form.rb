# frozen_string_literal: true

module Request
  class UntrashRequestForm < ApplicationForm
    has_one :untrash_activity, path: NS::ARGU[:untrashActivity]
  end
end
