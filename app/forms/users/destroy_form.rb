# frozen_string_literal: true

module Users
  class DestroyForm < ApplicationForm
    field :destroy_strategy, datatype: NS.xsd.string
    field :confirmation_string,
          path: NS.argu[:confirmationString],
          datatype: NS.xsd.string,
          min_count: 1
  end
end
