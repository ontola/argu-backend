# frozen_string_literal: true

class AuthorizedController < ApplicationController
  before_action :check_if_registered,
                except: %i(show move move! convert convert!)
  before_action :check_if_member,
                except: %i(show move move! convert convert!)
  before_action :authorize_show, only: :show
  before_action :authorize_action
  helper_method :authenticated_resource, :authenticated_context, :collect_banners

  rescue_from Argu::NotAMemberError, with: :handle_not_a_member_error

  protected

  def handle_not_a_member_error(exception)
    @_not_a_member_caught = true
    authorize exception.forum, :join?
    respond_to do |format|
      format.html do
        render template: 'forums/join',
               status: 403,
               locals: {
                 forum: exception.forum,
                 r: exception.r
               }
      end
      format.js do
        render partial: 'forums/join',
               layout: false,
               locals: {
                 forum: exception.forum,
                 r: exception.r
               }
      end
      format.json do
        f = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
        error_hash = {
          type: :error,
          error_id: 'NOT_A_MEMBER',
          message: exception.body,
          original_request: f.filter(params)
        }.merge(exception.body)
        render status: 403,
               json: error_hash.merge(notifications: [error_hash])
      end
    end
  end

  private

  def authorize_action
    authorize authenticated_resource, "#{params[:action].chomp('!')}?"
  end

  def authorize_show
    authorize authenticated_resource, :show?
  end

  def collect_banners
    @banners if @banners.present?

    banners = stubborn_hgetall('banners') || {}
    banners = JSON.parse(banners) if banners.present? && banners.is_a?(String)
    if authenticated_context.present?
      @banners = policy_scope(authenticated_context
                                .banners
                                .published)
                   .reject { |b| banners[b.identifier] == 'hidden' }
    end
  end

  # A version of {authenticated_resource!} that raises if the record cannot be found
  # @see {authenticated_resource!}
  # @raise [ActiveRecord::RecordNotFound]
  def authenticated_resource
    authenticated_resource! or raise ActiveRecord::RecordNotFound
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

  # Returns the tenant on which we're currently working. It is taken from {authenticated_resource!} if present,
  # otherwise the result from {resource_tenant} is used.
  # @author Fletcher91 <thom@argu.co>
  # @note This function isn't called context_tenant since we might use different
  #   scopes in the future (e.g. access to a project)
  # @note This should be based only on static information and be side-effect free to make memoization possible.
  # @return [Forum, nil] The {Forum} of the {authenticated_resource!} or from {resource_tenant}.
  def authenticated_context
    if resource_by_id.present?
      if resource_by_id.is_a?(Forum)
        resource_by_id
      elsif [Group, GroupMembership].include? resource_by_id.class
        resource_by_id.owner
      else
        resource_by_id.try(:forum)
      end
    else
      resource_tenant
    end
  end

  def check_if_member
    if current_profile.present? &&
        !(current_profile.member_of?(authenticated_context) ||
          current_profile.owner_of(authenticated_context) ||
          current_profile == authenticated_context.try(:page).try(:profile) ||
          current_user.profile.has_role?(:staff))
      raise Argu::NotAMemberError.new(forum: authenticated_context,
                                      r: redirect_url)
    end
  end

  def check_if_registered
    if current_profile.blank?
      raise Argu::NotAUserError.new(forum: authenticated_context,
                                    r: redirect_url)
    end
  end

  # Prepares a memoized {CreateService} for the relevant model for use in controller#create
  # @return [CreateService] The service, generally initialized with {current_profile} and {resource_new_params}
  # @example
  #   create_service # => CreateComment<commentable_id: 6, parent_id: 5>
  #   create_service.commit # => true (Comment created)
  def create_service
    @create_service ||= service_klass.new(
      get_parent_resource.edge,
      attributes: resource_new_params.merge(permit_params),
      options: service_options)
  end

  def service_klass
    "#{action_name.classify}#{controller_name.classify}".safe_constantize
  end

  # For use with the services options parameter, with sensible defaults
  # @return [Hash] Defaults with the creator and publisher set to the current profile/user
  def service_options(options = {})
    {
      creator: current_profile,
      publisher: current_user
    }.merge(options)
  end

  # Prepares a memoized {DestroyService} for the relevant model for use in controller#destroy
  # @return [DestroyService] The service, generally initialized with {resource_id}
  # @example
  #   destroy_service # => DestroyComment<commentable_id: 6, parent_id: 5>
  #   destroy_service.commit # => true (Comment destroyed)
  def destroy_service
    @destroy_service ||= service_klass.new(
      resource_by_id,
      options: service_options)
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
                    .new(resource_new_params))
      .owner
  end

  # @private
  def pundit_user
    UserContext.new(
      current_user,
      current_profile,
      session,
      authenticated_context,
      platform_open: platform_open?,
      within_user_cap: within_user_cap?)
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
      resource_by_id,
      options: service_options)
  end

  # Prepares a memoized {UntrashService} for the relevant model for use in controller#untrash
  # @return [UntrashService] The service, generally initialized with {resource_id}
  # @example
  #   untrash_service # => UntrashComment<commentable_id: 6, parent_id: 5>
  #   untrash_service.commit # => true (Comment untrashed)
  def untrash_service
    @untrash_service ||= service_klass.new(
      resource_by_id,
      options: service_options)
  end

  # Prepares a memoized {UpdateService} for the relevant model for use in controller#update
  # @return [UpdateService] The service, generally initialized with {resource_by_id} and {permit_params}
  # @example
  #   update_service # => UpdateComment<commentable_id: 6, parent_id: 5>
  #   update_service.commit # => true (Comment updated)
  def update_service
    @update_service ||= service_klass.new(
      resource_by_id,
      attributes: permit_params,
      options: service_options)
  end
end
