# frozen_string_literal: true
class GroupsController < ServiceController
  include NestedResourceHelper

  def show
    respond_to do |format|
      format.json_api do
        render json: authenticated_resource, include: %i(organization)
      end
    end
  end

  def settings
    if tab == 'members'
      @members = resource
                 .group_memberships
                 .includes(member: {profileable: :shortname})
                 .page(params[:page])
    end
    render locals: {
      tab: tab,
      active: tab,
      resource: resource_by_id
    }
  end

  private

  def create_respond_failure_html(resource)
    render 'pages/settings',
           locals: {
             tab: 'groups/new',
             active: 'groups',
             group: resource,
             resource: resource.page
           }
  end

  def new_resource_from_params
    resource = super
    resource.grants.build(
      edge: parent_edge,
      role: :member
    )
    resource
  end

  def new_respond_success_html(resource)
    render 'pages/settings', locals: {
      tab: 'groups/new',
      active: 'groups',
      group: resource,
      resource: resource.page
    }
  end

  def parent_edge
    parent_resource&.edge
  end

  def redirect_model_success(resource)
    settings_page_path(resource.page, tab: :groups)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      page: parent_resource!
    )
  end

  def respond_with_form_js(_)
    respond_js(
      'pages/settings',
      tab: 'groups/new',
      active: 'groups',
      group: resource,
      resource: resource.page
    )
  end

  def tab
    tab_param = params[:tab] || params[:group].try(:[], :tab)
    policy(resource_by_id || Group).verify_tab(tab_param)
  end

  def update_respond_failure_html(resource)
    render 'settings',
           locals: {
             tab: tab,
             active: tab,
             resource: resource
           }
  end
end
