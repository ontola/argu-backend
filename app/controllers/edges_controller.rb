# frozen_string_literal: true

class EdgesController < AuthorizedController
  def show
    redirect_to authenticated_resource.owner.iri.to_s
  end

  private

  def tree_root_id
    authenticated_resource.root_id
  end
end
