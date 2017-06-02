# frozen_string_literal: true
class GrantsController < ServiceController
  include NestedResourceHelper

  private

  def create_service
    @create_service ||= service_klass.new(
      nil,
      attributes: resource_new_params.merge(permit_params.to_h),
      options: service_options
    )
  end

  def create_respond_failure_html(resource)
    owner_path = authenticated_resource.edge.owner_type.pluralize.underscore
    render "#{owner_path}/settings",
           locals: {
             tab: 'grants/new',
             active: 'grants',
             page: resource.group.page,
             resource: authenticated_resource.edge.owner
           }
  end

  def parent_resource_key(_url_params)
    :page_id
  end

  def new_resource_from_params
    @resource ||= Grant.new(resource_new_params)
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
    if authenticated_resource.edge.owner_type == 'Forum'
      settings_forum_path(authenticated_resource.edge.owner, tab: :groups)
    else
      settings_page_path(authenticated_resource.edge.owner, tab: :groups)
    end
  end
  alias redirect_model_failure redirect_path
  alias redirect_model_success redirect_path

  def resource_new_params
    HashWithIndifferentAccess.new(
      edge_id: params[:edge_id] || get_parent_resource.edge.id,
      group_id: params[:group_id]
    )
  end

  def service_options
    super.except(:publisher, :creator)
  end
end
