# frozen_string_literal: true

class EdgesController < AuthorizedController
  def show
    if authenticated_resource.is_a?(Thing)
      super
    else
      redirect_to authenticated_resource.iri
    end
  end
end
