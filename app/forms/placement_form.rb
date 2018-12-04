# frozen_string_literal: true

class PlacementForm < RailsLD::Form
  fields %i[
    postal_code
    country_code
  ]
end
