# frozen_string_literal: true

module Users
  class UnlockPolicy < RestrictivePolicy
    def permitted_attribute_names
      %i[email]
    end

    def create?
      true
    end

    def update?
      false
    end
  end
end
