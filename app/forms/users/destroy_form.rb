# frozen_string_literal: true

module Users
  class DestroyForm < ApplicationForm
    field :destroy_strategy, datatype: NS::XSD[:string]
    field :confirmation_string,
          path: NS::ARGU[:confirmationString],
          datatype: NS::XSD[:string],
          min_count: 1
  end
end
