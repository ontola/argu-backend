# frozen_string_literal: true

class WidgetsController < ServiceController
  private

  def create_includes
    show_includes
  end

  def redirect_location
    parent_resource.widget_collection.iri
  end

  def invalidate_parent_collections_delta(resource)
    super + [[resource.parent.widget_collection.iri, NS.sp.Variable, NS.sp.Variable, delta_iri(:invalidate)]]
  end

  def update_success
    add_exec_action_header(response.headers, ontola_redirect_action(redirect_location))
    respond_with_resource(resource: current_resource, meta: update_meta, include: show_includes)
  end
end
