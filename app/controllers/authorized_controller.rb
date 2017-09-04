# frozen_string_literal: true

require 'argu/not_a_user_error'

class AuthorizedController < ApplicationController
  include Common::Setup
  include Common::Create,
          Common::Destroy,
          Common::Edit,
          Common::Index,
          Common::New,
          Common::Update
  before_action :check_if_registered,
                except: %i(show shift move convert convert!)
  before_action :authorize_action, except: :index
  before_bugsnag_notify :add_errors_tab
  helper_method :authenticated_edge, :authenticated_resource, :collect_banners

  # @private
  def user_context
    @_uc ||= UserContext.new(
      current_user,
      current_profile,
      doorkeeper_scopes,
      @_error_mode ? nil : authenticated_tree,
      session[:a_tokens]
    )
  end

  private

  def add_errors_tab(notification)
    return unless authenticated_resource&.errors.present?
    notification.add_tab(:errors, authenticated_resource.errors.to_h)
  end

  def authorize_action
    authorize authenticated_resource, "#{params[:action].chomp('!')}?"
  end

  def authenticated_edge
    @resource_edge ||= authenticated_resource!&.edge
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

  # The scope of the item used for authorization
  def authenticated_tree; end

  def check_if_registered
    return unless current_user.guest?
    raise Argu::NotAUserError.new(r: redirect_url)
  end

  def collect_banners
    @banners if @banners.present?

    banners = stubborn_hgetall('banners') || {}
    banners = JSON.parse(banners) if banners.present? && banners.is_a?(String)
    forum = current_forum
    return unless forum.present?
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

  def current_forum
    @current_forum ||= parent_resource.try(:parent_model, :forum)
  end

  def language_from_edge_tree
    return unless current_forum.present?
    I18n.available_locales.include?(current_forum.language) ? current_forum.language : :en
  end

  # Instantiates a new record of the current controller type initialized with {resource_new_params}
  # @return [ActiveRecord::Base] A fresh model instance
  def new_resource_from_params
    controller_class.new(resource_new_params)
  end

  def parent_resource
    resource_by_id.try(:parent_model)
  end

  def parent_resource!
    parent_resource || raise(ActiveRecord::RecordNotFound)
  end

  def permit_params
    params
      .require(model_name)
      .permit(*policy(resource_by_id || new_resource_from_params).permitted_attributes)
  end

  def redirect_url
    [request.path, request.query_string].reject(&:blank?).join('?')
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

  # Used in {authenticated_resource!} to build a new object. Overwrite this
  #   function if the model needs more than just the {Forum}
  # @return [Hash] The parameters to be used in {ActiveRecord::Base#new}
  def resource_new_params
    HashWithIndifferentAccess.new(
      forum: parent_resource!.is_a?(Forum) ? parent_resource! : parent_resource!.parent_model(:forum),
      publisher: current_user
    )
  end

  def resource_id
    params[:id] || params["#{model_name}_id"]
  end

  def _route?
    ![:new, :create].include? params[:action]
  end
end
