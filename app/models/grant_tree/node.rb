# frozen_string_literal: true

class GrantTree
  class Node
    include ActiveModel::Model
    include LinkedRails::Model

    attr_accessor :edge, :id, :children, :grant_tree, :parent, :permitted_actions, :grant_sets

    def initialize(edge, parent, grant_tree)
      self.edge = edge
      self.parent = parent
      self.id = edge.id
      self.grant_tree = grant_tree
      self.permitted_actions = parent.present? ? parent.permitted_actions.deep_dup : {}
      self.grant_sets = parent.present? ? dup_grant_sets(parent) : {}
      calculate_permitted_actions(grant_tree)
      grant_tree.cached_nodes[id] = self
    end

    # Adds a child to this node
    # @param [Edge] edge The child to add
    # @return [Edge] The child that was added
    def add_child(edge)
      raise 'Inconsistent node' unless edge.parent_id == id

      Node.new(edge, self, grant_tree)
    end

    def expired?
      @expired ||=
        parent&.expired? ||
        edge.expires_at && edge.expires_at < Time.current ||
        (edge.owner_type == 'VoteEvent' && edge.starts_at > Time.current)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def granted_group_ids(action: nil, resource_type: nil, parent_type: nil)
      if action.nil? && resource_type.nil? && parent_type.nil?
        return permitted_actions.values.map(&:values).flatten.map(&:values).flatten.uniq
      end

      parent_type ||= '*'
      ids = permitted_actions.dig(resource_type.to_s, action.to_s, parent_type.to_s) || []
      return ids if parent_type == '*'

      (ids + (permitted_actions.dig(resource_type.to_s, action.to_s, '*') || [])).uniq
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    def permission_groups
      @permission_groups ||= granted_group_ids.map { |id| PermissionGroup.new(id, self) }
    end

    def permitted_parent_types(action: nil, group_id: nil, resource_type: nil)
      permitted_actions
        .dig(resource_type.to_s, action.to_s)
        &.select { |_parent_type, ids| ids.include?(group_id) }
        &.keys || []
    end

    def trashed?
      @trashed ||= parent&.trashed? || edge.is_trashed?
    end

    def unpublished?
      @unpublished ||= parent&.unpublished? || !edge.is_published
    end

    private

    def calculate_permitted_actions(grant_tree) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      grant_tree.grant_resets_in_scope.select { |grant| grant.edge.path == edge.path }.each do |grant_reset|
        permitted_actions[grant_reset.resource_type][grant_reset.action] = {}
      end
      grant_tree
        .grants_in_scope
        .select { |grant| grant.edge.path == edge.path }
        .each do |grant|
        grant_sets[grant.group_id] ||= []
        grant.grant_set.iri
        grant_sets[grant.group_id] << grant.grant_set
        grant.permitted_actions.each do |permission|
          permitted_actions[permission.resource_type] ||= {}
          permitted_actions[permission.resource_type][permission.action] ||= {}
          permitted_actions[permission.resource_type][permission.action][permission.parent_type] ||= []
          permitted_actions[permission.resource_type][permission.action][permission.parent_type] << grant.group_id
        end
      end
    end

    def dup_grant_sets(parent)
      parent.grant_sets.dup.transform_values(&:dup)
    end
  end
end
