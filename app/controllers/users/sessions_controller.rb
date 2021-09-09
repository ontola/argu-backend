# frozen_string_literal: true

module Users
  class SessionsController < LinkedRails::Auth::SessionsController
    controller_class LinkedRails.session_class

    private

    def create_execute
      return true if requested_user.nil? || requested_user.encrypted_password.present?

      requested_user.send_reset_password_token_email
      current_resource.errors.add(:email, I18n.t('devise.failure.no_password'))

      false
    end

    def interact_as_guest?
      true
    end
  end
end
