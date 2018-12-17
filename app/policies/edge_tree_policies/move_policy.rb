# frozen_string_literal: true

class MovePolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[new_parent_id]
    attributes
  end

  def create?
    edgeable_policy.move?
  end
end
