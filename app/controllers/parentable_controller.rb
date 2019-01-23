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

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource!, :index_children?, controller_name
  end

  def current_forum
    @current_forum ||= parent_resource&.ancestor(:forum)
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
      parent_iri: parent_resource.iri
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
end
