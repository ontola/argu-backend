# frozen_string_literal: true

class EdgesController < AuthorizedController
  def show
    redirect_to authenticated_resource.iri
  end
end
