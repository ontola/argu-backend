# frozen_string_literal: true

class GroupsController < ServiceController
  private

  def new_resource_from_params
    resource = super
    resource.grants.build(
      edge: parent_resource,
      grant_set: GrantSet.participator
    )
    resource
  end

  def redirect_location
    settings_iri(authenticated_resource.page, tab: :groups)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      page: parent_resource!
    )
  end
end
