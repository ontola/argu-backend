# frozen_string_literal: true

module Users
  class PasswordPolicy < RestrictivePolicy
    def permitted_attribute_names
      if record.reset_password_token.present?
        %i[password password_confirmation reset_password_token]
      else
        %i[email]
      end
    end

    def create?
      true
    end

    def update?
      true
    end
  end
end
