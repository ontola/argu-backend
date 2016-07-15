# frozen_string_literal: true
class Users::PasswordsController < Devise::PasswordsController
  skip_filter :require_no_authentication, only: :create, if: :no_password_required?

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

  private

  def no_password_required?
    current_user && !current_user.password_required?
  end
end
