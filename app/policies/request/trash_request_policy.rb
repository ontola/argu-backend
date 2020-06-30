# frozen_string_literal: true

module Request
  class TrashRequestPolicy < RestrictivePolicy
    permit_nested_attributes %i[trash_activity]
  end
end
