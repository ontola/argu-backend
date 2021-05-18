# frozen_string_literal: true

class AuthorizedController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :check_if_registered, if: :check_if_registered?
  include Argu::Controller::Authorization

  before_action :verify_terms_accepted, only: %i[update create]
  before_action :verify_setup, only: %i[update create]
  prepend_before_action :authorize_current_actor
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

  def authorize_action
    return authorize authenticated_resource, :show? if form_action?

    authorize authenticated_resource, "#{params[:action].chomp('!')}?" unless action_name == 'index'
  end

  def authorize_current_actor
    authorize current_actor, :show?
  rescue Argu::Errors::Forbidden
    current_actor.actor = current_user.profile
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
    @authenticated_resource ||=
      case action_name
      when 'create', 'new'
        new_resource_from_params
      else
        requested_resource
      end
  end
  alias current_resource authenticated_resource!

  def check_if_registered
    return unless current_user.guest?

    raise Argu::Errors::Unauthorized.new(r: after_login_location)
  end

  def check_if_registered?
    action_name != 'show' && !form_action?
  end

  def current_forum; end

  def form_action?
    %w[new edit delete bin unbin shift settings].include?(action_name)
  end

  def language_from_edge_tree
    return if current_forum.blank?

    I18n.available_locales.include?(current_forum.language) ? current_forum.language : :en
  end

  # Instantiates a new record of the current controller type initialized with {resource_new_params}
  # @return [ActiveRecord::Base] A fresh model instance
  def new_resource_from_params
    controller_class.new(**resource_new_params)
  end

  def permit_params
    params
      .require(model_name)
      .permit(*policy(requested_resource || new_resource_from_params).permitted_attributes)
  end

  def policy(resource)
    user_context.tree_root_id.nil? && resource.is_a?(Edge) ? NoRootPolicy.new(user_context, resource) : super
  end

  def resource_from_params
    @resource_from_params ||=
      LinkedRails.resource_from_opts(ActsAsTenant.current_tenant, params.merge(class: controller_class))
  end

  # Searches the current primary resource by its id
  # @return [ActiveRecord::Base, nil] The resource by its id
  def requested_resource
    resource_from_params
  end

  # Searches the current primary resource by its id, raises if the record cannot be found
  # @return [ActiveRecord::Base, nil] The resource by its id
  # @raise [ActiveRecord::RecordNotFound]
  def requested_resource!
    requested_resource || raise(ActiveRecord::RecordNotFound)
  end

  # Used in {authenticated_resource!} to build a new object.
  # @return [Hash] The parameters to be used in {ActiveRecord::Base#new}
  def resource_new_params
    {}
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
    current_user.setup_finished?
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
