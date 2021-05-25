# frozen_string_literal: true

class GroupsController < ServiceController
  private

  def redirect_location
    settings_iri(authenticated_resource.page, tab: :groups)
  end
end
