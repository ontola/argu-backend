# frozen_string_literal: true

class GrantsController < ServiceController
  private

  def create_service_parent
    nil
  end

  def create_respond_failure_html(resource)
    owner_path = authenticated_resource.edge.owner_type.pluralize.underscore
    render "#{owner_path}/settings",
           locals: {
             tab: 'grants/new',
             active: 'grants',
             page: resource.group&.page,
             resource: authenticated_resource.edge
           }
  end

  def new_respond_success_html(resource)
    render 'pages/settings',
           locals: {
             tab: 'grants/new',
             active: 'groups',
             resource: resource.page,
             grant: resource
           }
  end

  def redirect_model_success(resource = nil)
    if resource.edge.owner_type == 'Forum'
      settings_iri_path(resource.edge)
    else
      settings_iri_path(resource.edge, tab: :groups)
    end
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      edge_id: params[:edge_id] || parent_resource!.uuid,
      group_id: params[:group_id],
      grant_set: GrantSet.participator
    )
  end

  def respond_with_form_js(resource)
    respond_js('pages/settings', tab: 'grants/new', active: 'groups', resource: resource.page, grant: resource)
  end

  def service_options
    super.except(:publisher, :creator)
  end
end
