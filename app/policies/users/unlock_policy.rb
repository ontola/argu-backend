# frozen_string_literal: true

module Users
  class UnlockPolicy < RestrictivePolicy
    permit_attributes %i[email]

    def create?
      true
    end

    def update?
      false
    end
  end
end
