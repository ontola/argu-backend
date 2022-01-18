# frozen_string_literal: true

class GrantTree
  class Node # rubocop:disable Metrics/ClassLength
    include ActiveModel::Model
    include LinkedRails::Model
    include URITemplateHelper

    attr_accessor :expires_at, :grant_tree, :id, :is_published, :trashed_at, :parent, :path
    attr_writer :edgeable_record, :grants, :grant_sets, :permitted_actions

    with_collection :permission_groups,
                    association_class: GrantTree::PermissionGroup,
                    policy_scope: false
    with_collection :grants,
                    policy_scope: false
    with_collection :grant_resets,
                    policy_scope: false

    # Adds a child to this node
    # @param [Hash] attrs The attributes of the Node to add
    # @return [Node] The child that was added
    def add_child(attrs)
      grant_tree.cached_nodes[attrs[:id]] ||= Node.new(
        grant_tree: grant_tree,
        parent: self,
        **attrs
      )
    end

    def description
      I18n.t('permissions.description')
    end

    def edgeable_record
      @edgeable_record ||= Edge.find(id)
    end

    def expired?
      @expired ||= parent&.expired? || (expires_at ? expires_at < Time.current : false)
    end

    def grant_sets
      @grant_sets ||= calculate_grant_sets
    end

    def grants
      @grants ||= calculate_grants
    end

    def grant_resets
      @grant_resets ||= grant_tree.grant_resets_in_scope.select { |grant| grant.edge.path == path }
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def granted_group_ids(action_name: nil, resource_type: nil, parent_type: nil)
      if action_name.nil? && resource_type.nil? && parent_type.nil?
        return permitted_actions.values.map(&:values).flatten.map(&:values).flatten.uniq
      end

      parent_type ||= '*'
      ids = permitted_actions.dig(resource_type.to_s, action_name.to_s, parent_type.to_s) || []
      return ids if parent_type == '*'

      (ids + (permitted_actions.dig(resource_type.to_s, action_name.to_s, '*') || [])).uniq
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def permission_groups
      @permission_groups ||= granted_group_ids.map { |id| PermissionGroup.new(group_id: id, node: self) }
    end

    def permitted_actions
      @permitted_actions ||= calculate_permitted_actions
    end

    def permitted_parent_types(action_name: nil, group_id: nil, resource_type: nil)
      permitted_actions
        .dig(resource_type.to_s, action_name.to_s)
        &.select { |_parent_type, ids| ids.include?(group_id) }
        &.keys || []
    end

    def singular_iri?
      true
    end

    def singular_iri_opts
      {
        parent_iri: split_iri_segments(edgeable_record&.root_relative_iri)
      }
    end

    def title
      I18n.t('permissions.label')
    end

    def trashed?
      @trashed ||= parent&.trashed? || (trashed_at ? trashed_at <= Time.current : false)
    end

    def unpublished?
      @unpublished ||= parent&.unpublished? || !is_published
    end

    private

    def add_permitted_actions(permission, grant) # rubocop:disable Metrics/AbcSize
      permitted_actions[permission.resource_type] ||= {}
      permitted_actions[permission.resource_type][permission.action_name] ||= {}
      permitted_actions[permission.resource_type][permission.action_name][permission.parent_type] ||= []
      permitted_actions[permission.resource_type][permission.action_name][permission.parent_type] << grant.group_id
    end

    def apply_grant_resets
      grant_resets.each do |grant_reset|
        permitted_actions[grant_reset.resource_type][grant_reset.action_name] = {}
      end
    end

    def apply_new_grants
      grant_tree
        .grants_in_scope
        .select { |grant| grant.edge.path == path }
        .each(&method(:apply_new_grant))
    end

    def apply_new_grant(grant)
      grants << grant

      grant_sets[grant.group_id] ||= []
      grant_sets[grant.group_id] << grant.grant_set

      grant.permitted_actions.each { |permission| add_permitted_actions(permission, grant) }
    end

    def calculate_grant_sets
      perform_calculations
      grant_sets
    end

    def calculate_grants
      perform_calculations
      grants
    end

    def calculate_permitted_actions
      perform_calculations
      permitted_actions
    end

    def dup_grant_sets(parent)
      parent.grant_sets.dup.transform_values(&:dup)
    end

    def perform_calculations # rubocop:disable Metrics/AbcSize
      return if @calculations_performed

      self.grant_sets = parent.present? ? dup_grant_sets(parent) : {}
      self.grants = parent.present? ? parent.grants.dup : []
      self.permitted_actions = parent.present? ? parent.permitted_actions.deep_dup : {}
      apply_grant_resets
      apply_new_grants

      @calculations_performed = true
    end

    class << self
      def requested_singular_resource(params, user_context)
        parent = LinkedRails.iri_mapper.parent_from_params(params, user_context)

        parent.grant_tree_node(user_context)
      end

      def singular_route_key
        :permissions
      end
    end
  end
end
