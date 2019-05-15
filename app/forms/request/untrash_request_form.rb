# frozen_string_literal: true

module Request
  class UntrashRequestForm < ApplicationForm
    fields [
      {untrash_activity: {path: NS::ARGU[:untrashActivity]}}
    ]
  end
end
