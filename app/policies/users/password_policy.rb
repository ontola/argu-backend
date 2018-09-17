# frozen_string_literal: true

module Users
  class PasswordPolicy < RestrictivePolicy
    def permitted_attribute_names
      %i[email]
    end

    def create?
      user.guest?
    end
  end
end
