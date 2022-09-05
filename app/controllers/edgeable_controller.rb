# frozen_string_literal: true

# Edgeable Controllers provide a standard interface for accessing resources
# present in the edge tree.
#
# Subclassed models are assumed to have `Edgeable` included.
#
# @see EdgeTree::Setup The interface for adjusting per-component behaviour.
class EdgeableController < ServiceController
  private

  def create_meta
    return [] if authenticated_resource.is_publishable? && !authenticated_resource.is_published?

    resource_added_delta(authenticated_resource)
  end

  def create_service_attributes
    super.merge(owner_type: controller_class.to_s)
  end

  def service_klass(action = action_name)
    "#{action.classify}#{controller_name.classify}".safe_constantize ||
      "#{action.classify}Edge".constantize
  end

  def update_meta
    return super unless current_resource.previously_changed_relations.include?('grant_collection')

    super + [
      invalidate_resource_delta(current_resource.granted_groups_iri)
    ]
  end
end
