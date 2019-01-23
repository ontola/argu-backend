# frozen_string_literal: true

class GroupsController < ServiceController
  private

  def default_form_view(action)
    return super unless %i[html js].include?(active_response_type)
    action.to_sym == :new ? 'pages/settings' : 'settings'
  end

  def default_form_view_locals(_action)
    {
      tab: tab!,
      active: tab!,
      resource: authenticated_resource
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

  def settings_success_html
    if tab! == 'members'
      @members = authenticated_resource
                   .group_memberships
                   .includes(member: {profileable: :shortname})
                   .page(params[:page])
    end
    respond_with_form(default_form_options(:settings))
  end

  def tab
    @tab ||= params[:tab] || params[:group].try(:[], :tab) || policy(authenticated_resource).default_tab
  end

  def tab!
    @verified_tab ||= policy(resource_by_id || Group).verify_tab(tab)
  end
end
