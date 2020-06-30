# frozen_string_literal: true

class CustomActionsController < EdgeableController
  private

  def redirect_location
    authenticated_resource.parent.iri
  end

  def show_includes
    %i[target]
  end

  def update_success
    add_exec_action_header(response.headers, ontola_redirect_action(redirect_location))
    respond_with_resource(resource: current_resource, meta: update_meta, include: show_includes)
  end
end
