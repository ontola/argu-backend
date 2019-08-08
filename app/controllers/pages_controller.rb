# frozen_string_literal: true

class PagesController < EdgeableController # rubocop:disable Metrics/ClassLength
  before_action :redirect_generic_shortnames, only: :show
  skip_before_action :authorize_action, only: %i[index]
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    authorize authenticated_resource, :list?
    return super unless action_name == 'show'
  end

  def create_success
    ActsAsTenant.current_tenant = authenticated_resource
    super
  end

  def create_success_rdf
    ActsAsTenant.current_tenant = authenticated_resource
    respond_with_redirect(location: authenticated_resource.iri, reload: true)
  end

  def destroy_success_html
    redirect_to root_path, status: 303, notice: t('type_destroy_success', type: t('pages.type'))
  end

  def destroy_failure_html
    flash[:error] = t('errors.general')
    redirect_to(delete_iri(authenticated_resource))
  end

  def handle_forbidden_html(_exception) # rubocop:disable Metrics/AbcSize
    us_po = policy(current_user) unless current_user.guest?
    return super unless us_po&.max_pages_reached? && request.format.html?
    errors = {}
    errors[:max_allowed_pages] = {
      max: us_po.max_allowed_pages,
      current: current_user.page_count,
      pages_url: pages_user_url(current_user)
    }
    render 'new', locals: {
      page: new_resource_from_params,
      errors: errors
    }
  end

  def index_collection
    @collection ||= ::Collection.new(
      collection_options.merge(
        association_base: discoverable_pages,
        association_class: Page,
        default_type: :paginated
      )
    )
  end

  def index_success_html
    skip_verify_policy_scoped(true)
    redirect_to discover_forums_path
  end

  def discoverable_pages
    ActsAsTenant.without_tenant { Kaminari.paginate_array(Page.discover.to_a) }
  end

  def new_execute
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
      creator: service_creator,
      publisher: service_publisher,
      is_published: true
    )
  end

  def permit_params
    return @_permit_params if defined?(@_permit_params) && @_permit_params.present?
    @_permit_params = super
    merge_photo_params(@_permit_params)
    @_permit_params[:last_accepted] = Time.current if %w[true 1].include?(@_permit_params[:last_accepted].to_s)
    @_permit_params
  end

  def redirect_generic_shortnames
    return if (/[a-zA-Z]/i =~ params[:id]).nil?
    resource = ActsAsTenant.without_tenant { Shortname.find_resource(params[:id]) }
    resource || raise(ActiveRecord::RecordNotFound)
    return if resource.is_a?(Page)
    redirect_to resource.iri
  end

  def policy(resource)
    return super unless resource.is_a?(Page)
    Pundit.policy(user_context, resource)
  end

  def redirect_current_resource?(_resource)
    false
  end

  def redirect_location
    return new_iri(nil, :pages) unless authenticated_resource.persisted?
    settings_iri(authenticated_resource, tab: tab)
  end

  def resource_by_id
    return if %w[new create].include?(action_name)

    @resource_by_id ||= ActsAsTenant.without_tenant { super } || ActsAsTenant.current_tenant
  end

  def show_success_html # rubocop:disable Metrics/AbcSize
    if resource_by_id != ActsAsTenant.current_tenant
      redirect_to "#{request.protocol}#{DynamicUriHelper.tenant_prefix(resource_by_id, true)}"
      return
    end

    @forums = policy_scope(authenticated_resource.forums)
                .includes(:default_cover_photo, :default_profile_photo, :shortname)
                .order('edges.follows_count DESC')
    @profile = authenticated_resource.profile

    if @forums.count == 1 && !policy(authenticated_resource).update?
      redirect_to @forums.first.iri
    else
      render 'show'
    end
  end
end
