# frozen_string_literal: true

module Request
  class UntrashRequestForm < ApplicationForm
    has_one :untrash_activity, path: NS.argu[:untrashActivity]
  end
end
