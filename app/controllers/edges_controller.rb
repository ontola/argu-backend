# frozen_string_literal: true

class EdgesController < AuthorizedController
  def show
    redirect_to authenticated_resource.owner.iri(only_path: true).to_s
  end

  private

  def resource_by_id
    @_resource_by_id ||=
      if uuid?(resource_id)
        Edge.find_by(uuid: resource_id)
      else
        Edge.find_by(id: resource_id)
      end
  end

  def tree_root_id
    authenticated_resource.root_id
  end
end
