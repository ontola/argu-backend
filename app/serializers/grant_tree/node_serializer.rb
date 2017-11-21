# frozen_string_literal: true

class GrantTree
  class NodeSerializer < BaseSerializer
    has_many :permission_groups, predicate: NS::ARGU[:permissionGroups]
  end
end
