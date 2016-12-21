# frozen_string_literal: true
require 'argu/not_a_user_error'

class AuthorizedController < ApplicationController
  before_action :check_if_registered,
                except: %i(show move move! convert convert!)
  before_action :authorize_action, except: :index
  helper_method :authenticated_resource, :collect_banners

  private

  def authorize_action
    authorize authenticated_resource, "#{params[:action].chomp('!')}?"
  end

  def collect_banners
    @banners if @banners.present?

    banners = stubborn_hgetall('banners') || {}
    banners = JSON.parse(banners) if banners.present? && banners.is_a?(String)
    forum = authenticated_resource.persisted_edge.get_parent(:forum).owner
    @banners = policy_scope(forum.banners.published)
                 .reject { |b| banners[b.identifier] == 'hidden' }
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
      when 'create'
        create_service.resource
      when 'destroy'
        destroy_service.resource
      when 'new'
        new_resource_from_params
      when 'update'
        update_service.resource
      when 'untrash'
        untrash_service.resource
      when 'trash'
        trash_service.resource
      else
        resource_by_id
      end
  end

  def check_if_registered
    return if current_profile.present?
    raise Argu::NotAUserError.new(r: redirect_url)
  end

  # Prepares a memoized {CreateService} for the relevant model for use in controller#create
  # @return [CreateService] The service, generally initialized with {current_profile} and {resource_new_params}
  # @example
  #   create_service # => CreateComment<commentable_id: 6, parent_id: 5>
  #   create_service.commit # => true (Comment created)
  def create_service
    @create_service ||= service_klass.new(
      get_parent_resource.edge,
      attributes: resource_new_params.merge(permit_params.to_h),
      options: service_options
    )
  end

  def service_klass
    "#{action_name.classify}#{controller_name.classify}".safe_constantize ||
      "#{action_name.classify}Service".constantize
  end

  # For use with the services options parameter, with sensible defaults
  # @return [Hash] Defaults with the creator and publisher set to the current profile/user
  def service_options(options = {})
    {
      creator: current_profile,
      publisher: current_user,
      uuid: a_uuid,
      client_id: request.session.id
    }.merge(options)
  end

  # Prepares a memoized {DestroyService} for the relevant model for use in controller#destroy
  # @return [DestroyService] The service, generally initialized with {resource_id}
  # @example
  #   destroy_service # => DestroyComment<commentable_id: 6, parent_id: 5>
  #   destroy_service.commit # => true (Comment destroyed)
  def destroy_service
    @destroy_service ||= service_klass.new(
      resource_by_id!,
      options: service_options
    )
  end

  # Instantiates a new record of the current controller type initialized with {resource_new_params}
  # @return [ActiveRecord::Base] A fresh model instance
  def new_resource_from_params
    get_parent_resource
      .edge
      .children
      .new(owner: controller_name
                    .classify
                    .constantize
                    .new(resource_new_params),
           parent: get_parent_resource.edge)
      .owner
  end

  def permit_params
    params
      .require(controller_name.singularize.to_sym)
      .permit(*policy(resource_by_id || new_resource_from_params).permitted_attributes)
  end

  # @private
  def pundit_user
    UserContext.new(
      current_user,
      current_profile,
      session[:a_tokens]
    )
  end

  def redirect_url
    [request.path, request.query_string].reject(&:blank?).join('?')
  end

  # Searches the current primary resource by its id
  # @return [ActiveRecord::Base, nil] The resource by its id
  def resource_by_id
    @_resource_by_id ||= controller_name
                         .classify
                         .constantize
                         .find_by id: resource_id
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
      forum: resource_tenant,
      publisher: current_user
    )
  end

  def resource_tenant
    Forum.find_via_shortname params[:forum_id] if params[:forum_id].present?
  end

  def resource_id
    params[:id] || params["#{controller_name.singularize}_id"]
  end

  def _route?
    ![:new, :create].include? params[:action]
  end

  # Prepares a memoized {TrashService} for the relevant model for use in controller#trash
  # @return [TrashService] The service, generally initialized with {resource_id}
  # @example
  #   trash_service # => TrashComment<commentable_id: 6, parent_id: 5>
  #   trash_service.commit # => true (Comment trashed)
  def trash_service
    @trash_service ||= service_klass.new(
      resource_by_id!,
      options: service_options
    )
  end

  # Prepares a memoized {UntrashService} for the relevant model for use in controller#untrash
  # @return [UntrashService] The service, generally initialized with {resource_id}
  # @example
  #   untrash_service # => UntrashComment<commentable_id: 6, parent_id: 5>
  #   untrash_service.commit # => true (Comment untrashed)
  def untrash_service
    @untrash_service ||= service_klass.new(
      resource_by_id!,
      options: service_options
    )
  end

  # Prepares a memoized {UpdateService} for the relevant model for use in controller#update
  # @return [UpdateService] The service, generally initialized with {resource_by_id} and {permit_params}
  # @example
  #   update_service # => UpdateComment<commentable_id: 6, parent_id: 5>
  #   update_service.commit # => true (Comment updated)
  def update_service
    @update_service ||= service_klass.new(
      resource_by_id!,
      attributes: permit_params,
      options: service_options
    )
  end
end
