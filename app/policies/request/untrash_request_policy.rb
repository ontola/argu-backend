# frozen_string_literal: true

module Request
  class UntrashRequestPolicy < RestrictivePolicy
    permit_nested_attributes %i[untrash_activity]
  end
end
