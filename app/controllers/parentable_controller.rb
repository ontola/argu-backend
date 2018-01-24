# frozen_string_literal: true

# Parentable Controllers provide a standard interface for accessing resources
# which have a relation to the edge tree
#
# Subclassed models are assumed to have `Parentable` included.
class ParentableController < AuthorizedController
  include NestedResourceHelper
  include UriTemplateHelper
  prepend_before_action :redirect_edge_parent_requests, only: :index
  helper_method :parent_resource

  private

  def authenticated_edge
    @resource_edge ||= authenticated_resource!&.edge
  end

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource!, :index_children?, controller_name
  end

  def current_forum
    @current_forum ||= parent_resource&.parent_model(:forum)
  end

  def linked_record_parent
    return if params[:linked_record_id].blank?
    @linked_record_parent ||=
      LinkedRecord.find_by(deku_id: params[:linked_record_id]) ||
      LinkedRecord.new_for_forum(params[:organization], params[:forum], params[:linked_record_id])
  end

  def parent_edge
    @parent_edge ||= parent_resource&.edge
  end

  def parent_edge!
    parent_edge || raise(ActiveRecord::RecordNotFound)
  end

  def parent_resource
    @parent_resource ||= super || resource_by_id_parent || linked_record_parent
  end

  def redirect_edge_parent_requests
    return unless parent_resource.is_a?(Edge)
    path = expand_uri_template(
      "#{controller_name}_collection_iri",
      parent_iri: parent_resource.owner.iri(only_path: true),
      only_path: true
    )
    redirect_to request.original_url.gsub(URI(request.original_url).path, path)
  end

  def resource_by_id_parent
    resource_by_id&.parent_model
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      forum: parent_resource!.is_a?(Forum) ? parent_resource! : parent_resource!.parent_model(:forum),
      publisher: current_user
    )
  end

  # The scope of the item used for authorization
  # @return [number] The id of the root edge.
  def tree_root_id
    @tree_root_id ||=
      case action_name
      when 'new', 'create', 'index'
        parent_edge&.root_id
      else
        resource_by_id.try(:edge)&.root_id
      end
  end
end
