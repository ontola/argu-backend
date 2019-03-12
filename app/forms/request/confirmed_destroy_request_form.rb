# frozen_string_literal: true

module Request
  class ConfirmedDestroyRequestForm < ApplicationForm
    fields %i[
      confirmation_string
    ]
  end
end
