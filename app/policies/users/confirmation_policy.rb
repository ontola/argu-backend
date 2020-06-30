# frozen_string_literal: true

module Users
  class ConfirmationPolicy < RestrictivePolicy
    permit_attributes %i[email]

    def create?
      user.guest?
    end
  end
end
