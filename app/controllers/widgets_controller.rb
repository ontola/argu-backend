# frozen_string_literal: true

class WidgetsController < ServiceController
  skip_before_action :check_if_registered, only: :index

  private

  def create_includes
    show_includes
  end

  def index_collection
    return super if params[:display]

    @index_collection ||=
      LinkedRails::Sequence.new(
        policy_scope(parent_resource.widgets),
        id: collection_iri(parent_resource, :widgets)
      )
  end

  def index_includes_collection
    return super if params[:display]

    {members: Widget.preview_includes}
  end

  def redirect_location
    parent_resource.widget_collection.iri(display: :table)
  end

  def resource_new_params
    {
      owner: parent_resource,
      widget_type: :custom,
      permitted_action: PermittedAction.find_by!(resource_type: parent_resource.owner_type, action: :show)
    }
  end

  def invalidate_parent_collections_delta(resource)
    super + [[resource.parent.widget_collection.iri, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)]]
  end

  def update_success
    add_exec_action_header(response.headers, ontola_redirect_action(redirect_location))
    respond_with_resource(resource: current_resource, meta: update_meta, include: show_includes)
  end
end
