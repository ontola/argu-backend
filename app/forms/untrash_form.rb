# frozen_string_literal: true

class UntrashForm < ApplicationForm
  self.abstract_form = true

  has_one :untrash_activity,
          form: ActivityForm,
          path: NS.argu[:untrashActivity],
          min_count: 1
end
