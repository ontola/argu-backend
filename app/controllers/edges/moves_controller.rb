# frozen_string_literal: true

class MovesController < ParentableController
  private

  def create_success
    respond_with_redirect(
      location: authenticated_resource.edge.iri,
      reload: true
    )
  end
end
