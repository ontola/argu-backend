# frozen_string_literal: true

class SubmissionForm < ApplicationForm
  field :coupon, min_count: 1
end
