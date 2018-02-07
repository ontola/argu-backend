# frozen_string_literal: true

class EdgesController < AuthorizedController
  def show
    redirect_to authenticated_resource.owner.iri.to_s
  end

  private

  def resource_by_id
    @_resource_by_id ||=
      if resource_id.match?(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
        Edge.find_by(uuid: resource_id)
      else
        Edge.find_by(id: resource_id)
      end
  end

  def tree_root_id
    authenticated_resource.root_id
  end
end
