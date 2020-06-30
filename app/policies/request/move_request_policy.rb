# frozen_string_literal: true

module Request
  class MoveRequestPolicy < RestrictivePolicy
    permit_attributes %i[new_parent_id]
  end
end
