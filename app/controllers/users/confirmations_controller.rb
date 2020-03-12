# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController # rubocop:disable Metrics/ClassLength
    include OauthHelper
    before_action :head_200, only: :show
    before_action :login_user, only: :show
    active_response :new, :show

    def create # rubocop:disable Metrics/AbcSize
      email = email_for_user
      create_email = SendEmailWorker.perform_async(
        :requested_confirmation,
        current_user.guest? ? {email: email.email, language: I18n.locale} : current_user.id,
        token_url: iri_from_template(:user_confirmation, confirmation_token: email.confirmation_token),
        email: email.email
      )
      add_exec_action_header(response.headers, ontola_snackbar_action(find_message(:send_instructions))) if create_email
      respond_with({}, location: after_resending_confirmation_instructions_path_for(current_user))
    end

    def confirm
      respond_to do |format|
        format.json do
          raise Argu::Errors::Forbidden.new(query: :confirm?) unless doorkeeper_scopes.include?('service')

          EmailAddress.find_by!(email: params[:email]).confirm
          head 200
        end
      end
    end

    protected

    def active_response_success_message; end

    def ld_action(opts = {})
      opts[:resource].action(ACTION_MAP[action_name.to_sym] || action_name, user_context)
    end

    def after_resending_confirmation_instructions_path_for(_resource)
      if correct_mail && !current_user.guest?
        current_user.menu(:profile).iri(fragment: :settings)
      else
        iri_from_template(:user_sign_in).path
      end
    end

    def after_sign_in_path_for(resource)
      return super if resource.url.present?

      iri_from_template(:setup_iri)
    end

    def correct_mail
      current_user.guest? ? true : resource_params[:email] == current_user.email
    end

    def default_form_view(action)
      action
    end

    def email_by_token
      @email_by_token ||= EmailAddress.find_first_by_auth_conditions(confirmation_token: original_token)
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

    def head_200
      head 200 if request.head?
    end

    def login_user
      return if current_user == current_resource.user

      sign_in current_resource.user
      active_response_block do
        respond_with_resource(resource: current_resource)
      end
    end

    def new_resource
      Users::Confirmation.new(user: current_user)
    end

    def original_token
      @original_token ||= params[:confirmation_token]
    end

    def resource_params
      params.fetch(resource_name, nil) ||
        params.fetch("#{resource_name.to_s.pluralize}/#{controller_name.singularize}", {})
    end

    def requested_resource
      Users::Confirmation.new(
        current_user: current_user,
        email: email_by_token,
        user: email_by_token&.user || raise(ActiveRecord::RecordNotFound),
        token: original_token
      )
    end

    def show_execute
      current_resource.confirm!
    end

    def show_failure
      respond_with_resource(
        resource: current_resource,
        notice: email_by_token.errors.full_messages.first
      )
    end

    def show_success
      respond_with_resource(
        resource: current_resource,
        notice: find_message(:confirmed)
      )
    end
  end
end
