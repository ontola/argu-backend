# frozen_string_literal: true

class UserContext
  class Node
    attr_accessor :id, :expired, :trashed, :unpublished, :children, :user_context, :grants_in_scope, :rules_in_scope
    alias expired? expired
    alias trashed? trashed
    alias unpublished? unpublished

    def self.build_from_tree(tree, root, user_context)
      root_node = build(root, nil, user_context)
      tree.delete(root)
      last_node = root_node
      while (index = tree.find_index { |n| n.parent_id == last_node.id })
        last_node = last_node.add_child(tree.delete_at(index))
      end
      raise 'Missing node' unless tree.empty?
      root_node
    end

    def self.build(edge, parent, user_context)
      n = Node.new
      n.id = edge.id
      n.expired = parent&.expired || edge.expires_at && edge.expires_at < DateTime.current
      n.expired = edge.owner.starts_at > DateTime.current if !n.expired && edge.owner_type == 'VoteEvent'
      n.trashed = parent&.trashed || edge.is_trashed?
      n.unpublished = parent&.unpublished || !edge.is_published
      n.user_context = user_context
      n.grants_in_scope = user_context.grants_in_scope.select { |grant| grant.edge.path == edge.path }
      n.rules_in_scope = user_context.rules_in_scope.select { |rule| rule.branch_id == n.id }
      user_context.cached_nodes[n.id] = n
      n
    end

    # Adds a child to this node
    # @param [Edge] edge The child to add
    # @return [Edge] The child that was added
    def add_child(edge)
      raise 'Inconsistent node' unless edge.parent_id == id
      c = Node.build(edge, self, user_context)
      c.grants_in_scope.concat(grants_in_scope)
      c.rules_in_scope.concat(rules_in_scope)
      c
    end
  end
end
