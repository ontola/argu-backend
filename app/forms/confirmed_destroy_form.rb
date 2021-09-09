# frozen_string_literal: true

class ConfirmedDestroyForm < ApplicationForm
  self.abstract_form = true

  field :confirmation_string,
        path: NS.argu[:confirmationString],
        datatype: NS.xsd.string,
        min_count: 1
end
