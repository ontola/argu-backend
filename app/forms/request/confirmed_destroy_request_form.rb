# frozen_string_literal: true

module Request
  class ConfirmedDestroyRequestForm < RailsLD::Form
    fields %i[
      confirmation_string
    ]
  end
end
