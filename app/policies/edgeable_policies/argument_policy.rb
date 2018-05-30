# frozen_string_literal: true

class ArgumentPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description pro] if create?
    attributes
  end
end
