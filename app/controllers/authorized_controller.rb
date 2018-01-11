# frozen_string_literal: true

require 'argu/errors/not_a_user'

class AuthorizedController < ApplicationController
  include Common::Setup
  include Common::Update
  include Common::New
  include Common::Index
  include Common::Edit
  include Common::Destroy
  include Common::Create
  include Common::Show
  before_action :check_if_registered, except: %i[show]
  before_action :authorize_action
  before_action :verify_terms_accepted, only: %i[update create]
  before_bugsnag_notify :add_errors_tab
  helper_method :authenticated_edge, :authenticated_resource, :collect_banners, :user_context

  # @private
  def user_context
    @_uc ||= UserContext.new(
      current_user,
      current_profile,
      doorkeeper_scopes,
      @_error_mode ? nil : authenticated_tree
    )
  end

  private

  def add_errors_tab(notification)
    return if authenticated_resource&.errors.blank?
    notification.add_tab(:errors, authenticated_resource.errors.to_h)
  end

  def authorize_action
    authorize authenticated_resource, "#{params[:action].chomp('!')}?" unless action_name == 'index'
  end

  def authenticated_edge; end

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

  # The scope of the item used for authorization
  def authenticated_tree; end

  def check_if_registered
    return unless current_user.guest?
    raise Argu::Errors::NotAUser.new(r: redirect_url)
  end

  def collect_banners
    return @banners if @banners
    @banners = []

    banners = stubborn_hgetall('banners') || {}
    banners = JSON.parse(banners) if banners.present? && banners.is_a?(String)
    forum = current_forum
    return if forum.blank?
    @banners = policy_scope(forum.banners.published)
                 .reject { |b| banners[b.identifier] == 'hidden' }
  end

  def collection_options
    params
      .permit(:page, filter: controller_class.filter_options.keys)
      .to_h
      .merge(user_context: user_context)
      .to_options
  end

  def controller_class
    controller_name.classify.constantize
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

  def redirect_url
    if request.method == 'GET' || authenticated_resource!.nil?
      [request.path, request.query_string].reject(&:blank?).join('?')
    else
      redirect_model_success(authenticated_resource)
    end
  end

  # Searches the current primary resource by its id
  # @return [ActiveRecord::Base, nil] The resource by its id
  def resource_by_id
    @_resource_by_id ||= controller_class.find_by(id: resource_id)
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

  def verify_terms_accepted
    return if current_user.guest? || current_user.accepted_terms?
    if accept_terms_param
      current_user.accept_terms!
    else
      respond_to do |format|
        format.js { render 'accept_terms' }
        format.json do
          render status: 403,
                 json: {
                   body: render_to_string('accept_terms.html', layout: false),
                   code: 'TERMS_NOT_ACCEPTED'
                 }
        end
        format.html { render 'accept_terms' }
      end
    end
  end
end
