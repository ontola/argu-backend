# frozen_string_literal: true

# Edgeable Controllers provide a standard interface for accessing resources
# present in the edge tree.
#
# Since this controller includes `NestedResourceHelper`, subclassed models
# are assumed to have `Edgeable` included.
#
# @see EdgeTree::Setup The interface for adjusting per-component behaviour.
class EdgeableController < ServiceController
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

  def redirect_current_resource?(resource)
    resource && !request.path.include?(resource.iri_path)
  end

  # Instantiates a new record of the current controller type initialized with {resource_new_params}
  # @return [ActiveRecord::Base] A fresh model instance
  def new_resource_from_params
    resource = super
    resource.parent = parent_resource!
    if resource.is_publishable?
      resource.build_argu_publication(
        published_at: Time.current,
        follow_type: resource.is_a?(BlogPost) ? 'news' : 'reactions'
      )
    end
    if params[:lat] && params[:lon]
      resource
        .custom_placements
        .new(params.permit(:lat, :lon, :zoom_level))
    end
    resource
  end

  def resource_from_params
    return @resource_from_params if instance_variable_defined?('@resource_from_params')
    resource = super
    redirect_to resource.iri_path if redirect_current_resource?(resource)
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

  def tree_root_id
    (resource_from_params || parent_resource)&.root_id
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
