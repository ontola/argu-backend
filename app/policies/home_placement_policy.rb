# frozen_string_literal: true

class HomePlacementPolicy < PlacementPolicy
  def permitted_attribute_names
    %i[postal_code country_code id]
  end
end
