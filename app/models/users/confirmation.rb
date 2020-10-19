# frozen_string_literal: true

module Users
  class Confirmation < LinkedRails::Auth::Confirmation
    include UriTemplateHelper

    def confirm!
      return false unless email&.confirm

      set_reset_password_token if reset_password?

      true
    end

    def confirmed?
      email&.confirmed?
    end

    class << self
      def form_class
        LinkedRails::Auth::ConfirmationForm
      end

      def policy_class
        LinkedRails::Auth::ConfirmationPolicy
      end
    end
  end
end
