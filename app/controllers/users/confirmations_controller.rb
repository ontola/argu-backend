# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  include OauthHelper
  skip_before_action :check_finished_intro, only: %i[show confirm]

  def create
    email = current_user.emails.find_by!(email: resource_params[:email])
    set_flash_message :notice, :send_instructions if email.send_confirmation_instructions
    redirect_back(fallback_location: settings_path(tab: :authentication))
  end

  def show
    @original_token = params[:confirmation_token]
    self.resource = email_by_token&.user
    return super if resource.nil? || resource.encrypted_password.present?
    render 'show'
  end

  def confirm
    @original_token = params[resource_name].try(:[], :confirmation_token)
    self.resource = email_by_token.user
    resource.assign_attributes(devise_parameter_sanitizer.sanitize(:sign_up))

    if resource.valid?
      email_by_token.confirm
      set_flash_message :notice, :confirmed
      sign_in resource
      redirect_to after_sign_in_path_for(resource)
    else
      render 'show'
    end
  end

  protected

  def after_resending_confirmation_instructions_path_for(resource)
    if correct_mail
      request.headers['Referer']
    else
      super
    end
  end

  def correct_mail
    current_user.guest? ? true : params[:user][:email] == current_user.email
  end

  def email_by_token
    @email_by_token ||= Email.find_first_by_auth_conditions(confirmation_token: @original_token)
  end
end
