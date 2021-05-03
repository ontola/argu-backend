# frozen_string_literal: true

module Users
  class PasswordsController < LinkedRails::Auth::PasswordsController
    private

    def after_sending_reset_password_instructions_path_for(_resource_name)
      iri_from_template(:user_sign_in).path
    end

    def after_resetting_password_path_for(resource)
      return iri_from_template(:user_sign_in).path if current_user.guest? || resource.setup_finished?

      iri_from_template(:setup_iri)
    end

    def assert_reset_token_passed
      raise Argu::Errors::Unauthorized.new if params[:reset_password_token].blank?
    end

    def create_execute
      if no_password_required?
        params[:user] ||= {}
        params[:user][:email] = current_user.email

        self.resource = resource_class.send_reset_password_instructions(resource_params)
        @current_resource = resource

        successfully_sent?(resource)
      else
        super
      end
    end

    def no_password_required?
      !current_user.guest? && !current_user.password_required?
    end

    def update_execute
      self.resource = resource_class.reset_password_by_token(resource_params)

      resource.primary_email_record.confirm if resource.errors.empty?
      @current_resource = resource

      resource.errors.empty?
    end
  end
end
