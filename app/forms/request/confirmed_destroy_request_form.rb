# frozen_string_literal: true

module Request
  class ConfirmedDestroyRequestForm < ApplicationForm
    field :confirmation_string,
          path: NS.argu[:confirmationString],
          datatype: NS.xsd.string,
          min_count: 1
  end
end
