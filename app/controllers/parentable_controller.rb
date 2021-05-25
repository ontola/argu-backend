# frozen_string_literal: true

# Parentable Controllers provide a standard interface for accessing resources
# which have a relation to the edge tree
#
# Subclassed models are assumed to have `Parentable` included.
class ParentableController < AuthorizedController
  include UriTemplateHelper
  prepend_before_action :redirect_index_requests, only: :index

  private

  def authorize_action
    return super unless action_name == 'index'

    authorize parent_resource!, :index_children?, controller_class, user_context: user_context
  end

  def parent_resource
    @parent_resource ||= requested_resource_parent || super
  end

  def redirect_index_requests
    return unless parent_resource.is_a?(Edge) && index_collection_or_view.is_a?(Collection) && params[:format].blank?

    correct_url = index_collection_or_view.iri.to_s

    redirect_to(correct_url) if correct_url != request.original_url
  end

  def requested_resource_parent
    requested_resource&.parent
  end
end
