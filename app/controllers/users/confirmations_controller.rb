# frozen_string_literal: true

module Users
  class ConfirmationsController < LinkedRails::Auth::ConfirmationsController
    include Argu::Controller::ErrorHandling
    include OauthHelper

    private

    def after_confirmation_path_for(_resource_name, resource)
      return super if current_user != resource.user || !resource.password_token

      iri_from_template(:user_set_password, reset_password_token: resource.password_token)
    end

    def after_resending_confirmation_instructions_path_for(_resource)
      if correct_mail && !current_user.guest?
        current_user.menu(:profile).iri(fragment: :settings)
      else
        iri_from_template(:user_sign_in).path
      end
    end

    def after_sign_in_path_for(resource)
      return super if setup_finished?

      iri_from_template(:setup_iri)
    end

    def correct_mail
      current_user.guest? ? true : resource_params[:email] == current_user.email
    end

    def create_execute
      email = email_for_user

      SendEmailWorker.perform_async(
        :requested_confirmation,
        current_user.guest? ? {email: email.email, language: I18n.locale} : current_user.id,
        token_url: iri_from_template(:user_confirmation, confirmation_token: email.confirmation_token),
        email: email.email
      )
    end

    def email_by_token
      return EmailAddress.find_by!(email: params[:email]) if doorkeeper_scopes.include?('service')

      @email_by_token ||= EmailAddress.find_first_by_auth_conditions(confirmation_token: original_token)
    end

    def email_for_user
      email = resource_params[:email]
      return EmailAddress.find_by!(email: email) if current_user.guest?

      current_user.email_addresses.find_by(email: email) ||
        raise(ActiveRecord::RecordNotFound.new(I18n.t('devise.confirmations.invalid_email', email: email)))
    end

    def requested_resource
      return unless email_by_token&.user

      @requested_resource ||=
        LinkedRails.confirmation_class.new(
          current_user: current_user,
          email: email_by_token,
          user: email_by_token.user,
          token: original_token
        )
    end

    def update_failure
      respond_with_redirect(
        location: after_confirmation_path_for(resource_name, current_resource),
        notice: email_by_token.errors.full_messages.first
      )
    end

    def update_success
      if doorkeeper_scopes.include?('service')
        head 200
      else
        sign_in current_resource.user if current_user != current_resource.user

        super
      end
    end
  end
end
