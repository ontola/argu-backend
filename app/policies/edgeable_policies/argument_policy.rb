# frozen_string_literal: true
class ArgumentPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i(title content pro) if create?
    attributes
  end
end
