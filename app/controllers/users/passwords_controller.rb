# frozen_string_literal: true
class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :require_no_authentication, only: :create, if: :no_password_required?

  def create
    if no_password_required?
      params[:user] ||= {}
      params[:user][:email] = current_user.email

      self.resource = resource_class.send_reset_password_instructions(resource_params)

      if successfully_sent?(resource)
        respond_with({}, location: settings_path)
      else
        respond_with(resource)
      end
    else
      super
    end
  end

  def sign_in(scope, resource)
    super(resource, scope)
  end

  def update
    super do
      if resource.persisted? && !resource.confirmed? && resource.confirmation_token.nil?
        resource.primary_email_record.confirm
      end
    end
  end

  private

  def no_password_required?
    !current_user.password_required?
  end
end
