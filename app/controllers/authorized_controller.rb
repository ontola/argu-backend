# frozen_string_literal: true

class AuthorizedController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :check_if_registered, if: :check_if_registered?
  include Argu::Controller::Authorization

  before_action :verify_terms_accepted, only: %i[update create]
  before_action :authorize_current_actor
  before_bugsnag_notify :add_errors_tab
  helper_method :authenticated_resource, :policy, :user_context

  active_response :index, :show

  private

  def add_errors_tab(notification)
    return if authenticated_resource&.errors.blank?
    notification.add_tab(:errors, authenticated_resource.errors.to_h)
  end

  def after_login_location
    return redirect_location if authenticated_resource!.present? && request.method != 'GET'
    request.original_url
  end

  def authorize_action
    authorize authenticated_resource, "#{params[:action].chomp('!')}?" unless action_name == 'index'
  end

  def authorize_current_actor
    authorize current_actor, :show?
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
    @resource ||=
      case action_name
      when 'create', 'new'
        new_resource_from_params
      else
        resource_by_id
      end
  end
  alias current_resource authenticated_resource!

  def check_if_registered
    return unless current_user.guest?
    raise Argu::Errors::Unauthorized.new(r: after_login_location)
  end

  def check_if_registered?
    !(action_name == 'show' || (afe_request? && action_name == 'new'))
  end

  def collection_options
    super.merge(
      filter: parse_filter(params[:filter], controller_class.try(:filter_options)),
      user_context: user_context,
      include_map: JSONAPI::IncludeDirective::Parser.parse_include_args([:root] + [show_includes])
    )
  end

  def current_forum; end

  def language_from_edge_tree
    return if current_forum.blank?
    I18n.available_locales.include?(current_forum.language) ? current_forum.language : :en
  end

  # Instantiates a new record of the current controller type initialized with {resource_new_params}
  # @return [ActiveRecord::Base] A fresh model instance
  def new_resource_from_params
    controller_class.new(resource_new_params)
  end

  def permit_params
    params
      .require(model_name)
      .permit(*policy(resource_by_id || new_resource_from_params).permitted_attributes)
  end

  def policy(resource)
    user_context.tree_root_id.nil? && resource.is_a?(Edge) ? NoRootPolicy.new(user_context, resource) : super
  end

  def resource_from_params
    @resource_from_params ||= resource_from_opts(ActsAsTenant.current_tenant, params.merge(class: controller_class))
  end

  # Searches the current primary resource by its id
  # @return [ActiveRecord::Base, nil] The resource by its id
  def resource_by_id
    resource_from_params
  end

  # Searches the current primary resource by its id, raises if the record cannot be found
  # @return [ActiveRecord::Base, nil] The resource by its id
  # @raise [ActiveRecord::RecordNotFound]
  def resource_by_id!
    resource_by_id || raise(ActiveRecord::RecordNotFound)
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

  def verify_terms_accepted # rubocop:disable Metrics/AbcSize
    return if current_user.guest? || current_user.accepted_terms?
    if accept_terms_param
      current_user.accept_terms!
    else
      active_response_block do
        case active_response_type
        when :html, :js
          render 'accept_terms'
        when :json
          render status: 403,
                 json: {
                   body: render_to_string('accept_terms.html', layout: false),
                   code: 'TERMS_NOT_ACCEPTED'
                 }
        else
          action = new_iri(
            expand_uri_template(:terms_iri), nil, query: {referrer: request.headers['Request-Referrer']}.to_param
          )
          add_exec_action_header(response.headers, ontola_dialog_action(action))
          head 200
        end
      end
    end
  end
end
