# frozen_string_literal: true

class MovePolicy < EdgeTreePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[new_parent_id]
    attributes
  end

  def create?
    edgeable_policy.move?
  end
end
