# frozen_string_literal: true

class GrantsController < ServiceController
  private

  def redirect_location
    settings_iri(authenticated_resource.root, tab: :groups)
  end
end
