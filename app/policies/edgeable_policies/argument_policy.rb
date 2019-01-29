# frozen_string_literal: true

class ArgumentPolicy < EdgePolicy
  def class_name
    'ProArgument'
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name description pro]
    attributes
  end
end
