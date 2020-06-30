# frozen_string_literal: true

class HomePlacementPolicy < PlacementPolicy
  permit_attributes %i[postal_code country_code id _destroy]
end
