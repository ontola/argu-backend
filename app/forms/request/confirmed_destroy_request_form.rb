# frozen_string_literal: true

module Request
  class ConfirmedDestroyRequestForm < FormsBase
    fields %i[
      confirmation_string
    ]
  end
end
