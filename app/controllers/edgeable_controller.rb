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
    @action_service ||=
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
    return [] if authenticated_resource.is_publishable? && !authenticated_resource.is_published?

    resource_added_delta(authenticated_resource)
  end

  def create_service_attributes
    super.merge(owner_type: controller_class.to_s)
  end

  def guest_creator?
    current_user.guest? && !controller_class.include?(RedisResource::Concern)
  end

  def service_creator
    return super unless guest_creator?

    Profile.community
  end

  def service_klass
    "#{action_name.classify}#{controller_name.classify}".safe_constantize ||
      "#{action_name.classify}Edge".constantize
  end

  def service_publisher
    return super unless guest_creator?

    User.community
  end

  # Prepares a memoized {TrashService} for the relevant model for use in controller#trash
  # @return [TrashService] The service, generally initialized with {resource_id}
  # @example
  #   trash_service # => TrashComment<commentable_id: 6, parent_id: 5>
  #   trash_service.commit # => true (Comment trashed)
  def trash_service
    @trash_service ||= service_klass.new(
      requested_resource!,
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
      requested_resource!,
      options: service_options
    )
  end

  def update_meta # rubocop:disable Metrics/AbcSize
    meta = super
    if current_resource.previously_changed_relations.include?('grant_collection')
      meta.concat(
        GrantTree.new(current_resource.root).granted_groups(current_resource).map do |granted_group|
          [current_resource.iri, NS.argu[:grantedGroups], granted_group.iri, delta_iri(:replace)]
        end
      )
    end
    meta
  end
end
