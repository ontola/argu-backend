# frozen_string_literal: true

module Users
  class Confirmation < LinkedRails::Auth::Confirmation
    include UriTemplateHelper

    attr_accessor :email

    delegate :confirmed?, to: :email!

    def confirm!
      return false unless email!&.confirm

      set_reset_password_token if reset_password?

      true
    end

    def email!
      email || raise(ActiveRecord::RecordNotFound)
    end

    private

    def reset_password?
      user.present? && user.encrypted_password.blank?
    end

    def set_reset_password_token
      self.password_token = user.send(:set_reset_password_token)
    end

    class << self
      def iri_value
        name.demodulize
      end

      def email_to_confirm(params, user_context)
        return EmailAddress.find_by!(email: params[:email]) if user_context&.doorkeeper_scopes&.include?('service')

        EmailAddress.find_first_by_auth_conditions(confirmation_token: params[:confirmation_token])
      end

      def requested_singular_resource(params, user_context)
        email = email_to_confirm(params, user_context)

        return new if email.blank? && !params.key?(:confirmation_token)
        return if email.blank?

        new(
          confirmation_token: params[:confirmation_token],
          email: email,
          user: email.user
        )
      end
    end
  end
end
