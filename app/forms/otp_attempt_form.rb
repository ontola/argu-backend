# frozen_string_literal: true

class OtpAttemptForm < ApplicationForm
  field :otp_attempt, description: '', min_count: 1
end
