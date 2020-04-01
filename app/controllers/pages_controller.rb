# frozen_string_literal: true

class PagesController < EdgeableController
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

  def index_collection
    @index_collection ||= ::Collection.new(
      collection_options.merge(
        association_base: discoverable_pages,
        association_class: Page,
        default_type: :paginated
      )
    )
  end

  def discoverable_pages
    ActsAsTenant.without_tenant { Kaminari.paginate_array(Page.discover.to_a) }
  end

  def new_execute
    authenticated_resource.build_shortname
    authenticated_resource.build_profile
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

  def redirect_location
    return new_iri(nil, :pages) unless authenticated_resource.persisted?

    settings_iri(authenticated_resource, tab: tab)
  end

  def resource_by_id
    return if %w[new create].include?(action_name)

    @resource_by_id ||= ActsAsTenant.without_tenant { super } || ActsAsTenant.current_tenant
  end

  def update_meta
    meta = super
    if current_resource.previous_changes.key?(:primary_container_node_id)
      meta << invalidate_resource_delta(current_resource.menu(:navigations))
    end
    meta
  end

  def update_success
    return super unless current_resource.previous_changes.key?(:url)

    respond_with_redirect(location: current_resource.iri, reload: true)
  end
end
