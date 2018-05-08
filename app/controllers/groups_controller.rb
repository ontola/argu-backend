# frozen_string_literal: true

class GroupsController < ServiceController
  def settings
    if tab! == 'members'
      @members = resource
                   .group_memberships
                   .includes(member: {profileable: :shortname})
                   .page(params[:page])
    end
    render locals: {
      tab: tab!,
      active: tab!,
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

  def include_show
    %i[organization]
  end

  def new_resource_from_params
    resource = super
    resource.grants.build(
      edge: parent_edge,
      grant_set: GrantSet.participator
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

  def redirect_model_success(resource)
    settings_iri_path(resource.page, tab: :groups)
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
    @tab ||= params[:tab] || params[:group].try(:[], :tab) || policy(authenticated_resource).default_tab
  end

  def tab!
    @verified_tab ||= policy(resource_by_id || Group).verify_tab(tab)
  end

  def tree_root_id
    @tree_root_id ||=
      case action_name
      when 'new', 'create', 'index'
        parent_edge&.root_id
      else
        resource_by_id&.page&.edge&.root_id
      end
  end

  def update_respond_failure_html(resource)
    render 'settings',
           locals: {
             tab: tab!,
             active: tab!,
             resource: resource
           }
  end
end
