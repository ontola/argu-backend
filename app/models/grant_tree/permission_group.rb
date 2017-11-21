# frozen_string_literal: true

class GrantTree
  class PermissionGroup
    include ActiveModel::Model
    include Iriable

    attr_accessor :node, :group_id
    alias read_attribute_for_serialization send

    def initialize(group_id, node)
      self.group_id = group_id
      self.node = node
    end

    def group
      Group.find(group_id)
    end

    def iri_opts
      {group_id: group_id, edge_id: node.id}
    end

    def permissions
      PermittedAction::RESOURCE_TYPES.map do |permission|
        Permission.new(self, node, permission)
      end
    end
  end
end
