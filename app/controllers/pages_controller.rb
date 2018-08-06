# frozen_string_literal: true

class PagesController < EdgeableController
  prepend_before_action :redirect_generic_shortnames, only: :show
  skip_before_action :authorize_action, only: %i[settings index]
  skip_before_action :check_if_registered, only: :index

  self.inc_nested_collection = [
    default_view: {member_sequence: {members: :default_profile_photo}},
    filters: [],
    operation: ACTION_FORM_INCLUDES
  ].freeze

  self.inc_nested_collection = [
    default_view: {member_sequence: :members},
    filters: [],
    operation: ACTION_FORM_INCLUDES
  ].freeze

  def settings
    authorize authenticated_resource, :update?

    render locals: {
      tab: tab!,
      active: tab!,
      resource: authenticated_resource
    }
  end

  protected

  def authenticated_resource!
    @resource ||=
      case action_name
      when 'create', 'new'
        new_resource_from_params
      when 'trash', 'untrash', 'index'
        nil
      else
        resource_by_id
      end
  end

  private

  def authorize_action
    authorize authenticated_resource, :list?
    return super unless action_name == 'show'
  end

  def create_success
    user_context.tree_root_id = authenticated_resource.uuid
    super
  end

  def create_failure_html
    render 'new',
           locals: {
             page: authenticated_resource,
             errors: authenticated_resource.errors
           },
           notifications: [{type: :error, message: 'Fout tijdens het aanmaken'}]
  end

  def create_failure_js
    respond_js('pages/new', page: authenticated_resource, errors: authenticated_resource.errors)
  end

  def destroy_success_html
    redirect_to root_path, status: 303, notice: t('type_destroy_success', type: t('pages.type'))
  end

  def destroy_failure_html
    flash[:error] = t('errors.general')
    redirect_to(delete_page_path(authenticated_resource))
  end

  def execute_action
    return super unless action_name == 'create'
    authenticated_resource.assign_attributes(permit_params)

    if authenticated_resource.save
      active_response_handle_success
    else
      active_response_handle_failure
    end
  end

  def handle_forbidden_html(_exception)
    us_po = policy(current_user) unless current_user.guest?
    return super unless us_po&.max_pages_reached? && request.format.html?
    errors = {}
    errors[:max_allowed_pages] = {
      max: us_po.max_allowed_pages,
      current: current_user.edges.where(owner_type: 'Page').length,
      pages_url: pages_user_url(current_user)
    }
    render 'new', locals: {
      page: new_resource_from_params,
      errors: errors
    }
  end

  def index_collection
    @collection ||= ::Collection.new(
      association_class: Page,
      user_context: user_context,
      association_scope: :discover
    )
  end

  def show_includes
    [
      :default_profile_photo
    ]
  end

  def new_execute_html
    authenticated_resource.build_shortname
    authenticated_resource.build_profile
  end

  def new_view_locals
    {
      page: authenticated_resource,
      errors: {}
    }
  end

  def new_resource_from_params
    Page.new(
      creator: current_profile,
      publisher: current_user,
      is_published: true
    )
  end

  def permit_params
    return @_permit_params if defined?(@_permit_params) && @_permit_params.present?
    @_permit_params = super
    merge_photo_params(@_permit_params, Page.new)
    @_permit_params[:last_accepted] = Time.current if permit_params[:last_accepted] == '1'
    @_permit_params
  end

  def redirect_generic_shortnames
    return if (/[a-zA-Z]/i =~ params[:id]).nil?
    resource = Shortname.find_resource(params[:id]) || raise(ActiveRecord::RecordNotFound)
    return if resource.is_a?(Page)
    redirect_to resource.iri_path
  end

  def policy(resource)
    return super unless resource.is_a?(Page)
    Pundit.policy(user_context, resource)
  end

  def settings_view
    'settings'
  end
  alias edit_view settings_view

  def settings_view_locals
    {resource: authenticated_resource, tab: tab!, active: tab!}
  end
  alias edit_view_locals settings_view_locals

  def redirect_location
    return new_page_path unless authenticated_resource.persisted?
    settings_iri_path(authenticated_resource, tab: tab)
  end

  def show_success_html
    @forums = policy_scope(authenticated_resource.forums)
                .includes(:default_cover_photo, :default_profile_photo, :shortname)
                .order('edges.follows_count DESC')
    @profile = authenticated_resource.profile

    if @forums.count == 1 && !policy(authenticated_resource).update?
      redirect_to @forums.first.iri_path
    elsif (/[a-zA-Z]/i =~ params[:id]).nil?
      redirect_to authenticated_resource.iri(only_path: true).to_s, status: 307
    else
      render 'show'
    end
  end

  def tab!
    @verified_tab ||= policy(authenticated_resource || Page).verify_tab(tab)
  end

  def tab
    @tab ||= params[:tab] || policy(authenticated_resource).default_tab
  end
end
