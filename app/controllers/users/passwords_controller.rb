# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  include OauthHelper

  skip_before_action :require_no_authentication, only: :create, if: :no_password_required?
  active_response :new, :edit

  def create # rubocop:disable Metrics/AbcSize
    if no_password_required?
      params[:user] ||= {}
      params[:user][:email] = current_user.email

      self.resource = resource_class.send_reset_password_instructions(resource_params)

      if successfully_sent?(resource)
        respond_with({}, location: settings_iri('/u'))
      else
        respond_with(resource)
      end
    else
      super
    end
  end

  def update
    super do |resource|
      resource.primary_email_record.confirm if resource.errors.blank?
    end
  end

  private

  def ld_action(opts = {})
    opts[:resource].action(ACTION_MAP[action_name.to_sym] || action_name, user_context)
  end

  def after_sending_reset_password_instructions_path_for(_resource_name)
    RDF::DynamicURI(path_with_hostname('/u/sign_in')).path
  end

  def after_resetting_password_path_for(resource)
    return super if resource.url.present?

    iri_from_template(:setup_iri)
  end

  def current_resource
    @current_resource ||= Users::Password.new(user: current_user, reset_password_token: params[:reset_password_token])
  end

  def default_form_view_locals(_action)
    {
      resource: resource
    }
  end

  def default_form_view(action)
    action
  end

  def edit_execute
    self.resource = resource_class.new
    set_minimum_password_length
    resource.reset_password_token = params[:reset_password_token]
  end

  def new_execute
    self.resource = resource_class.new
  end

  def no_password_required?
    !current_user.guest? && !current_user.password_required?
  end

  def resource_params
    params.fetch(resource_name, nil) ||
      params.fetch("#{resource_name.to_s.pluralize}/#{controller_name.singularize}", {})
  end

  def sign_in(scope, resource)
    super(resource, scope)
  end
end
