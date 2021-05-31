# frozen_string_literal: true

class CustomActionsController < EdgeableController
  private

  def redirect_location
    authenticated_resource.parent.iri
  end

  def update_success
    respond_with_resource(
      resource: current_resource,
      include: show_includes
    )
  end
end
