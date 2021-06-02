# frozen_string_literal: true

class PagesController < EdgeableController
  before_action :redirect_generic_shortnames, only: :show

  private

  def authorize_action
    return super unless action_name == 'index' && parent_resource.is_a?(User)

    authorize(parent_resource, :update?)
  end

  def create_success
    ActsAsTenant.current_tenant = authenticated_resource
    super
  end

  def create_success_rdf
    ActsAsTenant.current_tenant = authenticated_resource
    respond_with_redirect(location: authenticated_resource.iri, reload: true)
  end

  def permit_params
    return @_permit_params if defined?(@_permit_params) && @_permit_params.present?

    @_permit_params = super
    merge_photo_params(@_permit_params)
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

    settings_iri(authenticated_resource)
  end

  def new_resource
    @new_resource ||= ActsAsTenant.without_tenant { super } || ActsAsTenant.current_tenant
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
