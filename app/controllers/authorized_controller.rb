
class AuthorizedController < ApplicationController
  before_action :check_if_registered,
                only: %i(new create delete destroy edit update)
  before_action :check_if_member,
                only: %i(new create delete destroy edit update)
  before_action :authorize_show, only: :show
  before_action :authorize_action
  helper_method :authenticated_context

  rescue_from Argu::NotAUserError do |exception|
    @_not_a_user_caught = true
    @resource ||= User.new(r: exception.r, shortname: Shortname.new)
    respond_to do |format|
      format.js  do
        render 'devise/sessions/new',
               status: 401,
               layout: false,
               locals: {
                   resource: @resource,
                   resource_name: :user,
                   devise_mapping: Devise.mappings[:user],
                   r: exception.r
               }
      end
      format.html do
        redirect_to new_user_session_path(r: exception.r)
      end
    end
  end

  rescue_from Argu::NotAMemberError do |exception|
    @_not_a_member_caught = true
    authorize exception.forum, :join?
    respond_to do |format|
      format.html { render template: 'forums/join', locals: { forum: exception.forum, r: exception.r } }
      format.js { render partial: 'forums/join', layout: false, locals: { forum: exception.forum, r: exception.r } }
      format.json { render json: exception.body, status: 403 }
    end
  end

  private

  def authorize_action
    # The check can be removed when (at least) memberships_controller is migrated to use a proper membership id
    if authenticated_resource!.present?
      authorize authenticated_resource!, "#{params[:action].chomp('!')}?"
    end
  end

  def authorize_show
    authorize authenticated_resource!, :show?
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
      raise Argu::NotAUserError.new(authenticated_context,
                                    redirect_url)
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
    @resource = if params[:action] == 'new' || params[:action] == 'create'
      controller_name
          .classify
          .constantize
          .new resource_new_params
    else
      controller_name
          .classify
          .constantize
          .find_by id: params[:id]
    end
  end

  # Used in {authenticated_resource!} to build a new object. Overwrite this function if the model needs more than just the {Forum}
  # @return [Hash] The parameters to be used in {ActiveRecord::Base#new}
  def resource_new_params
    {
      forum: tenant_by_param
    }
  end

  # Returns the tenant on which we're currently working. It is taken from {authenticated_resource!} if present,
  # otherwise the result from {tenant_by_param} is used.
  # @author Fletcher91 <thom@argu.co>
  # @note This function isn't called context_tenant since we might use different scopes in the future (e.g. access to a project)
  # @note This should be based only on static information and be side-effect free to make memoization possible.
  # @return [Forum, nil] The {Forum} of the {authenticated_resource!} or from {tenant_by_param}.
  def authenticated_context
    if authenticated_resource!.present?
      authenticated_resource!.is_a?(Forum) ?
        authenticated_resource! :
        authenticated_resource!.forum
    else
      tenant_by_param
    end
  end

  # @private
  def naming_context
    authenticated_context
  end

  # @private
  def pundit_user
    UserContext.new(current_user,
                    current_profile,
                    session,
                    authenticated_context,
                    {
                      platform_open: platform_open?,
                      within_user_cap: within_user_cap?
                    })
  end

  def tenant_by_param
    Forum.find_via_shortname params[:forum_id]
  end

  def redirect_url
    [request.path, request.query_string].reject(&:blank?).join('?')
  end

  def _route?
    ![:new, :create].include? params[:action]
  end
end
