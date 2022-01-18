# frozen_string_literal: true

class GrantTree
  class PermissionGroup
    include ActiveModel::Model
    include LinkedRails::Model

    attr_accessor :node, :group_id

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
      GrantReset.resource_types.keys.map do |permission|
        Permission.new(self, node, permission)
      end
    end
  end
end
