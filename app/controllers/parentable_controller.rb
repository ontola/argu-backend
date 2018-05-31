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
    @resource_edge ||= authenticated_resource!
  end

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource!, :index_children?, controller_name
  end

  def current_forum
    @current_forum ||= parent_resource&.parent_model(:forum)
  end

  def linked_record_parent(opts = params)
    return unless parent_resource_param(opts) == 'linked_record_id'
    @linked_record_parent ||=
      LinkedRecord.find_by(deku_id: opts[:linked_record_id]) ||
      LinkedRecord.new_for_forum(opts[:root_id], opts[:forum_id], opts[:linked_record_id])
  end

  def parent_resource
    @parent_resource ||= linked_record_parent || resource_by_id_parent || super
  end

  def redirect_edge_parent_requests
    return unless parent_resource == Edge
    path = expand_uri_template(
      "#{controller_name}_collection_iri",
      parent_iri: parent_resource.iri(only_path: true),
      only_path: true
    )
    redirect_to request.original_url.gsub(URI(request.original_url).path, path)
  end

  def resource_by_id_parent
    resource_from_params&.parent
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      publisher: current_user
    )
  end

  def root_from_params
    @root_from_params ||= Page.find_via_shortname_or_id(params[:root_id] || params[:page_id])
  end

  # The scope of the item used for authorization
  # @return [number] The id of the root edge.
  def tree_root_id
    @tree_root_id ||=
      case action_name
      when 'new', 'create', 'index'
        parent_resource&.root_id
      else
        (resource_by_id.is_a?(Edge) ? resource_by_id : resource_by_id.try(:edge))&.root_id
      end
  end
end
