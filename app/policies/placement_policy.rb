# frozen_string_literal: true

class PlacementPolicy < RestrictivePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[postal_code country_code id]
    attributes
  end
end
