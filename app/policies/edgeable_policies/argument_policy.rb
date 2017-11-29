# frozen_string_literal: true

class ArgumentPolicy < EdgeablePolicy
  def permitted_attributes
    attributes = super
    attributes.concat %i[title content pro] if create?
    attributes
  end
end
