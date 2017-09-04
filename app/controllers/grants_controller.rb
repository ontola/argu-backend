# frozen_string_literal: true

class GrantsController < ServiceController
  include NestedResourceHelper

  private

  def create_service_parent
    nil
  end

  def create_respond_failure_html(resource)
    owner_path = authenticated_edge.owner_type.pluralize.underscore
    render "#{owner_path}/settings",
           locals: {
             tab: 'grants/new',
             active: 'grants',
             page: resource.group.page,
             resource: authenticated_edge.owner
           }
  end

  def parent_resource_key(_url_params)
    :page_id
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

  def redirect_path(_ = nil)
    if authenticated_edge.owner_type == 'Forum'
      settings_forum_path(authenticated_edge.owner)
    else
      settings_page_path(authenticated_edge.owner, tab: :groups)
    end
  end
  alias redirect_model_failure redirect_path
  alias redirect_model_success redirect_path

  def resource_new_params
    HashWithIndifferentAccess.new(
      edge_id: params[:edge_id] || parent_resource!.edge.id,
      group_id: params[:group_id]
    )
  end

  def respond_with_form_js(resource)
    respond_js('pages/settings', tab: 'grants/new', active: 'groups', resource: resource.page, grant: resource)
  end

  def service_options
    super.except(:publisher, :creator)
  end
end
