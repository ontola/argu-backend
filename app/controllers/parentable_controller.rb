# frozen_string_literal: true

# Parentable Controllers provide a standard interface for accessing resources
# which have a relation to the edge tree
#
# Subclassed models are assumed to have `Parentable` included.
class ParentableController < AuthorizedController
  include NestedResourceHelper
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

  def parent_edge
    @parent_edge ||= parent_resource&.edge
  end

  def parent_edge!
    parent_edge || raise(ActiveRecord::RecordNotFound)
  end

  def parent_resource
    super || resource_by_id_parent
  end

  def parent_resource!
    parent_resource || raise(ActiveRecord::RecordNotFound)
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
end
