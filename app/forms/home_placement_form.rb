# frozen_string_literal: true

class HomePlacementForm < ApplicationForm
  fields %i[
    postal_code
    country_code
  ]
end
