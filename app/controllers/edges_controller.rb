# frozen_string_literal: true

class EdgesController < AuthorizedController
  def show
    redirect_to authenticated_resource.iri_path
  end

  private

  def tree_root_id
    authenticated_resource.root_id
  end
end
