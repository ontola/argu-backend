# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  include OauthHelper

  def create
    email = current_user.email_addresses.find_by!(email: resource_params[:email])
    set_flash_message :notice, :send_instructions if email.send_confirmation_instructions
    redirect_back(fallback_location: settings_path(tab: :authentication))
  end

  def show
    @original_token = params[:confirmation_token]
    self.resource = email_by_token&.user
    return super if resource.nil? || resource.encrypted_password.present?
    email_by_token.confirm
    sign_in resource
    set_flash_message :notice, :confirmed
    render 'show'
  end

  def confirm
    respond_to do |format|
      format.html do
        @original_token = params[resource_name].try(:[], :confirmation_token)
        self.resource = email_by_token!.user
        raise Argu::NotAuthorizedError.new(query: :confirm?) if resource.encrypted_password.present?

        resource.assign_attributes(devise_parameter_sanitizer.sanitize(:sign_up))

        if resource.save
          redirect_to after_sign_in_path_for(resource)
        else
          render 'show'
        end
      end
      format.json do
        raise Argu::NotAuthorizedError.new(query: :confirm?) unless doorkeeper_scopes.include?('service')
        EmailAddress.find_by!(email: params[:email]).confirm
        head 200
      end
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

  def after_sign_in_path_for(resource)
    return super if resource.url.present?
    setup_users_path
  end

  def correct_mail
    current_user.guest? ? true : params[:user][:email] == current_user.email
  end

  def email_by_token
    @email_by_token ||= EmailAddress.find_first_by_auth_conditions(confirmation_token: @original_token)
  end

  def email_by_token!
    email_by_token || raise(ActiveRecord::RecordNotFound)
  end
end
