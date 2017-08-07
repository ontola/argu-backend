# frozen_string_literal: true

# Edge Tree Controllers provide a standard interface for accessing resources
# present in the edge tree.
#
# Since this controller includes `NestedResourceHelper`, subclassed models
# are assumed to have `Edgeable` included.
#
# @see EdgeTree::Setup The interface for adjusting per-component behaviour.
class EdgeTreeController < ServiceController
  include NestedResourceHelper,
          EdgeTree::Trashing

  private

  def action_service
    @_action_service ||=
      case action_name
      when 'untrash'
        untrash_service
      when 'trash'
        trash_service
      else
        super
      end
  end

  # The scope of the item used for authorization
  def authenticated_tree
    @_tree ||=
      case action_name
      when 'new', 'create', 'index'
        parent_edge&.self_and_ancestors
      when 'update'
        resource_by_id&.edge&.self_and_ancestors
      else
        authenticated_edge&.self_and_ancestors
      end
  end

  def current_forum
    (resource_by_id || current_resource_is_nested? && parent_resource)
      .try(:parent_model, :forum)
      &.parent_model(:forum)
  end

  # Instantiates a new record of the current controller type initialized with {resource_new_params}
  # @return [ActiveRecord::Base] A fresh model instance
  def new_resource_from_params
    resource = parent_resource!
                 .edge
                 .children
                 .new(owner: controller_class.new(resource_new_params),
                      parent: parent_edge)
                 .owner
    if resource.is_publishable?
      resource.edge.build_argu_publication(
        publish_type: 'direct',
        published_at: DateTime.current,
        follow_type: resource.is_a?(BlogPost) ? 'news' : 'reactions'
      )
    end
    resource.build_happening(created_at: DateTime.current) if resource.is_happenable?
    resource
  end

  def parent_edge
    @parent_edge ||= parent_resource&.edge
  end

  def parent_edge!
    parent_edge || raise(ActiveRecord::RecordNotFound)
  end

  # Method to determine where the action should redirect to after it succeeds.
  # @param [Class] resource The resource from the result of the action
  def redirect_model_success(resource)
    return resource.parent_model if action_name == 'trash'
    super
  end

  # Prepares a memoized {TrashService} for the relevant model for use in controller#trash
  # @return [TrashService] The service, generally initialized with {resource_id}
  # @example
  #   trash_service # => TrashComment<commentable_id: 6, parent_id: 5>
  #   trash_service.commit # => true (Comment trashed)
  def trash_service
    @trash_service ||= service_klass.new(
      resource_by_id!,
      options: service_options
    )
  end

  # Prepares a memoized {UntrashService} for the relevant model for use in controller#untrash
  # @return [UntrashService] The service, generally initialized with {resource_id}
  # @example
  #   untrash_service # => UntrashComment<commentable_id: 6, parent_id: 5>
  #   untrash_service.commit # => true (Comment untrashed)
  def untrash_service
    @untrash_service ||= service_klass.new(
      resource_by_id!,
      options: service_options
    )
  end
end
