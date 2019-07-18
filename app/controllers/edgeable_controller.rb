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

  def create_meta
    !resource.is_publishable? || resource.is_published? ? resource_added_delta(resource) : []
  end

  def default_publication_follow_type
    'reactions'
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
        follow_type: default_publication_follow_type
      )
    end
    if params[:lat] && params[:lon]
      resource
        .build_custom_placement(params.permit(:lat, :lon, :zoom_level))
    end
    resource
  end

  def resource_from_params
    return @resource_from_params if instance_variable_defined?('@resource_from_params')
    resource = super
    redirect_to resource.iri if redirect_current_resource?(resource)
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

  def tree_root_fallback
    return unless controller_name == 'pages' || controller_name == 'forums' && %w[index discover].include?(action_name)

    super
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

  def update_meta # rubocop:disable Metrics/AbcSize
    meta = super
    if current_resource.previously_changed_relations.include?('grant_collection')
      meta << [current_resource.iri, NS::ARGU[:grantedGroups], LinkedRails::NS::SP[:Variable], NS::LL[:remove]]
      meta.concat(
        GrantTree.new(current_resource.root).granted_groups(current_resource).map do |granted_group|
          [current_resource.iri, NS::ARGU[:grantedGroups], granted_group.iri, delta_iri(:add)]
        end
      )
    end
    meta
  end
end
