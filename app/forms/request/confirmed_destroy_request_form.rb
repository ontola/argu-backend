# frozen_string_literal: true

module Request
  class ConfirmedDestroyRequestForm < ApplicationForm
    fields [
      {confirmation_string: {path: NS::ARGU[:confirmationString], datatype: NS::XSD[:string]}}
    ]
  end
end
