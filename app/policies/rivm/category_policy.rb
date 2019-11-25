# frozen_string_literal: true

class CategoryPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name]
    attributes
  end
end
