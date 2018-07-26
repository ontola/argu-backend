# frozen_string_literal: true

class GroupsController < ServiceController
  def settings
    if tab! == 'members'
      @members = authenticated_resource
                   .group_memberships
                   .includes(member: {profileable: :shortname})
                   .page(params[:page])
    end
    render locals: {
      tab: tab!,
      active: tab!,
      resource: authenticated_resource
    }
  end

  private

  def default_form_view(_action)
    'pages/settings'
  end

  def default_form_view_locals(_action)
    {
      tab: tab!,
      active: tab!,
      resource: authenticated_resource.page
    }
  end

  def new_view_locals
    {
      tab: 'groups/new',
      active: 'groups',
      group: authenticated_resource,
      resource: authenticated_resource.page
    }
  end

  def show_includes
    %i[organization]
  end

  def new_resource_from_params
    resource = super
    resource.grants.build(
      edge: parent_resource,
      grant_set: GrantSet.participator
    )
    resource
  end

  def redirect_location
    settings_iri_path(authenticated_resource.page, tab: :groups)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      page: parent_resource!
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
        parent_resource&.root_id
      else
        resource_by_id&.page&.root_id
      end
  end
end
