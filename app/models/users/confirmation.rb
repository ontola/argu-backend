# frozen_string_literal: true

module Users
  class Confirmation < LinkedRails::Auth::Confirmation
    include UriTemplateHelper

    def confirm!
      return false unless email&.confirm

      set_reset_password_token if reset_password?

      true
    end

    def redirect_url
      return if current_user != user
      return @redirect_url if @redirect_url

      return @redirect_url = ActsAsTenant.current_tenant.iri unless password_token

      @redirect_url = iri_from_template(:user_set_password, reset_password_token: password_token)
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
