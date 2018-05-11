# frozen_string_literal: true

# Edgeable Controllers provide a standard interface for accessing resources
# present in the edge tree.
#
# Since this controller includes `NestedResourceHelper`, subclassed models
# are assumed to have `Edgeable` included.
#
# @see EdgeTree::Setup The interface for adjusting per-component behaviour.
class EdgeableController < ServiceController
  include EdgeTree::Trashing

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
        published_at: Time.current,
        follow_type: resource.is_a?(BlogPost) ? 'news' : 'reactions'
      )
    end
    if params[:lat] && params[:lon]
      resource
        .edge
        .custom_placements
        .new(params.permit(:lat, :lon, :zoom_level))
    end
    resource.build_happening(created_at: Time.current) if resource.is_happenable?
    resource
  end

  def resource_from_params
    return @resource_from_params if instance_variable_defined?('@resource_from_params')
    resource = super
    redirect_to resource.iri_path if resource && resource.class != controller_class
    resource
  end

  def service_klass
    "#{action_name.classify}#{controller_name.classify}".safe_constantize ||
      "Edgeable#{action_name.classify}Service".constantize
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
