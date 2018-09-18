# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  include OauthHelper
  active_response :new

  def create
    email = email_for_user
    create_email = SendEmailWorker.perform_async(
      :requested_confirmation,
      current_user.guest? ? {email: email.email, language: I18n.locale} : current_user.id,
      confirmationToken: email.confirmation_token,
      email: email.email
    )
    set_flash_message :notice, :send_instructions if create_email
    respond_with({}, location: after_resending_confirmation_instructions_path_for(resource))
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
        raise Argu::Errors::Forbidden.new(query: :confirm?) if resource.encrypted_password.present?

        resource.assign_attributes(devise_parameter_sanitizer.sanitize(:sign_up))

        if resource.save
          redirect_to after_sign_in_path_for(resource)
        else
          render 'show'
        end
      end
      format.json do
        raise Argu::Errors::Forbidden.new(query: :confirm?) unless doorkeeper_scopes.include?('service')
        EmailAddress.find_by!(email: params[:email]).confirm
        head 200
      end
    end
  end

  protected

  def active_response_action(opts = {})
    opts[:resource].action(user_context, ACTION_MAP[action_name.to_sym] || action_name)
  end

  def after_resending_confirmation_instructions_path_for(_resource)
    if correct_mail && !current_user.guest?
      settings_path(tab: :authentication)
    else
      afe_request? ? '/u/sign_in' : new_user_session_path
    end
  end

  def after_sign_in_path_for(resource)
    return super if resource.url.present?
    setup_users_path
  end

  def correct_mail
    current_user.guest? ? true : resource_params[:email] == current_user.email
  end

  def current_resource
    @current_resource ||= Users::Confirmation.new(user: current_user)
  end

  def default_form_view_locals(_action)
    {
      resource: resource
    }
  end

  def default_form_view(action)
    action
  end

  def email_by_token
    @email_by_token ||= EmailAddress.find_first_by_auth_conditions(confirmation_token: @original_token)
  end

  def email_by_token!
    email_by_token || raise(ActiveRecord::RecordNotFound)
  end

  def email_for_user
    email = resource_params[:email]
    return EmailAddress.find_by!(email: email) if current_user.guest?
    current_user.email_addresses.find_by(email: email) ||
      raise(ActiveRecord::RecordNotFound.new(I18n.t('devise.confirmations.invalid_email', email: email)))
  end

  def new_execute
    self.resource = resource_class.new
  end

  def resource_params
    params.fetch(resource_name, nil) ||
      params.fetch("#{resource_name.to_s.pluralize}/#{controller_name.singularize}", {})
  end
end
