# frozen_string_literal: true

class WidgetsController < ServiceController
  private

  def create_includes
    show_includes
  end

  def invalidate_parent_collections_delta(resource)
    super + [[resource.parent.collection_iri(:widgets), NS.sp.Variable, NS.sp.Variable, delta_iri(:invalidate)]]
  end

  def update_success
    respond_with_resource(resource: current_resource, meta: update_meta, include: show_includes)
  end
end
