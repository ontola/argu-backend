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

  def built_associations(action)
    action
      .included_object
      .class
      .reflect_on_all_associations
      .select { |association| association.has_one? && action.included_object.association(association.name).loaded? }
      .map(&:name)
  end

  def check_if_registered?
    return !create_as_guest? if %(create destroy trash).include?(action_name)

    super && action_name != 'index'
  end

  def collection_include_map
    JSONAPI::IncludeDirective::Parser.parse_include_args(%i[root shortname])
  end

  def collection_view_includes(_member_includes = {})
    {member_sequence: {}}
  end

  def create_as_guest?
    controller_class.include?(RedisResource::Concern) || controller_class == Submission
  end

  def create_meta
    return [] if authenticated_resource.is_publishable? && !authenticated_resource.is_published?

    resource_added_delta(authenticated_resource)
  end

  def default_publication_follow_type
    'reactions'
  end

  def form_resource_includes(action)
    includes = super
    return includes unless action_name == 'new' && action.included_object

    includes = [includes] if includes.is_a?(Hash)
    includes + built_associations(action)
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
    resource
  end

  def resource_new_params
    super.merge(owner_type: controller_name.classify)
  end

  def service_klass
    "#{action_name.classify}#{controller_name.classify}".safe_constantize ||
      "#{action_name.classify}Edge".constantize
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
          [current_resource.iri, NS::ARGU[:grantedGroups], granted_group.iri, delta_iri(:replace)]
        end
      )
    end
    meta
  end
end
