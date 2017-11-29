# frozen_string_literal: true

class GrantTree
  class Node
    attr_accessor :id, :expired, :trashed, :unpublished, :children, :grant_tree, :grants_in_scope, :rules_in_scope
    alias expired? expired
    alias trashed? trashed
    alias unpublished? unpublished

    def self.build(edge, parent, grant_tree)
      n = Node.new
      n.id = edge.id
      n.expired = parent&.expired || edge.expires_at && edge.expires_at < Time.current
      n.expired = edge.owner.starts_at > Time.current if !n.expired && edge.owner_type == 'VoteEvent'
      n.trashed = parent&.trashed || edge.is_trashed?
      n.unpublished = parent&.unpublished || !edge.is_published
      n.grant_tree = grant_tree
      n.grants_in_scope = grant_tree.grants_in_scope.select { |grant| grant.edge.path == edge.path }
      n.rules_in_scope = grant_tree.rules_in_scope.select { |rule| rule.branch_id == n.id }
      grant_tree.cached_nodes[n.id] = n
      n
    end

    # Adds a child to this node
    # @param [Edge] edge The child to add
    # @return [Edge] The child that was added
    def add_child(edge)
      raise 'Inconsistent node' unless edge.parent_id == id
      c = Node.build(edge, self, grant_tree)
      c.grants_in_scope.concat(grants_in_scope)
      c.rules_in_scope.concat(rules_in_scope)
      c
    end
  end
end
