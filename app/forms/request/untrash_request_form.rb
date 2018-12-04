# frozen_string_literal: true

module Request
  class UntrashRequestForm < RailsLD::Form
    fields %i[
      untrash_activity
    ]
  end
end
