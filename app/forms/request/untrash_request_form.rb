# frozen_string_literal: true

module Request
  class UntrashRequestForm < FormsBase
    fields %i[
      untrash_activity
    ]
  end
end
