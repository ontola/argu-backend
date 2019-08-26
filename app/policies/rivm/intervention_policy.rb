# frozen_string_literal: true

class InterventionPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description]
    attributes
  end
end