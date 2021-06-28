# frozen_string_literal: true

class GrantTree
  class NodeSerializer < BaseSerializer
    has_many :permission_groups, predicate: NS.argu[:permissionGroups]
  end
end
