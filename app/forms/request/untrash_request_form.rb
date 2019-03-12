# frozen_string_literal: true

module Request
  class UntrashRequestForm < ApplicationForm
    fields %i[
      untrash_activity
    ]
  end
end
