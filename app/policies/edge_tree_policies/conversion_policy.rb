# frozen_string_literal: true

class ConversionPolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i[klass]
    attributes
  end

  def create?
    rule is_manager?, is_super_admin?, super
  end
end
