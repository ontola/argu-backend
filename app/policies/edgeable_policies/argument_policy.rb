# frozen_string_literal: true

class ArgumentPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope; end

  def permitted_attributes
    attributes = super
    attributes.concat %i[title content pro] if create?
    attributes
  end

  def update?
    rule (is_member? && is_creator?), is_manager?, is_super_admin?, super
  end
end
