# frozen_string_literal: true

class MovePolicy < EdgeTreePolicy
  permit_attributes %i[new_parent_id]

  def create?
    edgeable_policy.move?
  end
end
