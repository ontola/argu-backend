# frozen_string_literal: true
class GrantsController < AuthorizedController
  include NestedResourceHelper

  def new
    render "#{authenticated_resource.edge.owner_type.pluralize.underscore}/settings",
           locals: {
             tab: 'grants/new',
             active: 'grants',
             resource: authenticated_resource.edge.owner,
             grant: authenticated_resource
           }
  end

  def create
    create_service.on(:create_grant_successful) do
      respond_to do |format|
        format.html do
          redirect_to redirect_path
        end
      end
    end
    create_service.on(:create_grant_failed) do |grant|
      respond_to do |format|
        format.html do
          render "#{authenticated_resource.edge.owner_type.pluralize.underscore}/settings",
                 locals: {
                   tab: 'grants/new',
                   active: 'grants',
                   page: grant.group.page,
                   resource: grant
                 }
        end
      end
    end
    create_service.commit
  end

  def destroy
    destroy_service.on(:destroy_grant_successful) do
      respond_to do |format|
        format.html do
          redirect_to redirect_path
        end
      end
    end
    destroy_service.on(:destroy_grant_failed) do
      respond_to do |format|
        flash[:error] = t('error')
        format.html { redirect_to redirect_path }
      end
    end
    destroy_service.commit
  end

  private

  def create_service
    @create_service ||= service_klass.new(
      get_parent_resource,
      attributes: resource_new_params.merge(permit_params.to_h),
      options: service_options
    )
  end

  def parent_resource_param(_url_params)
    :edge_id
  end

  def new_resource_from_params
    @resource ||= Grant.new(resource_new_params)
  end

  def redirect_path
    if authenticated_resource.edge.owner_type == 'Forum'
      settings_forum_path(authenticated_resource.edge.owner, tab: :groups)
    else
      settings_page_path(authenticated_resource.edge.owner, tab: :groups)
    end
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      edge: get_parent_resource,
      group_id: params[:group_id]
    )
  end

  def service_options
    super.except(:publisher, :creator)
  end
end
