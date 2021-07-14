# frozen_string_literal: true

class AuthorizedController < ApplicationController
  before_action :check_if_registered, if: :check_if_registered?
  include Argu::Controller::Authorization

  before_action :verify_terms_accepted, only: %i[update create]
  before_action :verify_setup, only: %i[update create]
  before_bugsnag_notify :add_errors_tab

  active_response :index, :show

  private

  def add_errors_tab(notification)
    return if authenticated_resource!&.errors.blank?

    notification.add_tab(:errors, authenticated_resource.errors.to_h)
  end

  def after_login_location
    return redirect_location if authenticated_resource!.present? && request.method != 'GET'

    request.original_url
  end

  # A version of {authenticated_resource!} that raises if the record cannot be found
  # @see {authenticated_resource!}
  # @raise [ActiveRecord::RecordNotFound]
  def authenticated_resource
    authenticated_resource! || raise(ActiveRecord::RecordNotFound)
  end

  # Searches for the resource of the current controllers' type by `id`
  # If the action is one where a resource can't exist yet, a new one is created with the tenant set.
  # @see {NestedResourceHelper} For finding parent resources
  # @author Fletcher91 <thom@argu.co>
  # @return [ActiveRecord::Base, nil] The model by id, a new model if the action was either `new` or `create`.
  def authenticated_resource!
    current_resource
  end

  def check_if_registered
    return unless current_user.guest?

    raise Argu::Errors::Unauthorized.new(r: after_login_location)
  end

  def check_if_registered?
    return false if SAFE_METHODS.include?(request.method)
    return true if doorkeeper_token.nil?

    !interact_as_guest?
  end

  def interact_as_guest?
    controller_class.try(:interact_as_guest?)
  end

  def form_action?
    current_resource.is_a?(Actions::Item)
  end

  def permit_param_key
    model_name
  end

  def permit_param_keys
    @permit_param_keys ||= policy(requested_resource || new_resource).permitted_attributes
  end

  def policy(resource)
    user_context.tree_root_id.nil? && resource.is_a?(Edge) ? NoRootPolicy.new(user_context, resource) : super
  end

  def resource_id
    params[:id] || params["#{model_name}_id"]
  end

  def _route?
    !%i[new create].include? params[:action]
  end

  def requires_setup?
    !(current_user.guest? || !tree_root.requires_intro? || setup_finished?)
  end

  def setup_finished?
    current_user.finished_intro?
  end

  def verify_setup
    return unless requires_setup?

    active_response_block do
      action = iri_from_template(:setup_iri)
      add_exec_action_header(response.headers, ontola_dialog_action(action))
      head 449
    end
  end

  def verify_terms_accepted # rubocop:disable Metrics/AbcSize
    return if current_user.guest? || current_user.accepted_terms?

    if accept_terms_param
      current_user.update(accept_terms: true)
      current_user.send_reset_password_token_email if current_user.encrypted_password.blank?
    else
      action = new_iri(expand_uri_template(:policy_agreements_iri), nil)
      add_exec_action_header(response.headers, ontola_dialog_action(action))
      head 449
    end
  end
end
