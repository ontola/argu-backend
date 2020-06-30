# frozen_string_literal: true

module Request
  class ConfirmedDestroyRequestPolicy < RestrictivePolicy
    permit_attributes %i[confirmation_string]
  end
end
