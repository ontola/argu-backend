# frozen_string_literal: true

module Users
  class PasswordsController < LinkedRails::Auth::PasswordsController
    private

    def after_sending_reset_password_instructions_path_for(_resource_name)
      iri_from_template(:user_sign_in).path
    end

    def after_resetting_password_path_for(_resource)
      iri_from_template(:user_sign_in).path
    end

    def assert_reset_token_passed
      raise Argu::Errors::Unauthorized.new if params[:reset_password_token].blank?
    end

    def create_execute
      if no_password_required?
        params[:user] ||= {}
        params[:user][:email] = current_user.email

        @current_resource = resource_class.send_reset_password_instructions(resource_params)
        successfully_sent?(current_resource)
      else
        super
      end
    end

    def no_password_required?
      !current_user.guest? && !current_user.password_required?
    end

    def update_execute
      @current_resource = resource_class.reset_password_by_token(resource_params)

      current_resource.primary_email_record.confirm if current_resource.errors.empty?

      current_resource.errors.empty?
    end
  end
end
