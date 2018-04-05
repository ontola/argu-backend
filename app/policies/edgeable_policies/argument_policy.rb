# frozen_string_literal: true

class ArgumentPolicy < EdgeablePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[title content pro] if create?
    attributes
  end
end
