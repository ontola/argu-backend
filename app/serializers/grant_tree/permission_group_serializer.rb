# frozen_string_literal: true

class GrantTree
  class PermissionGroupSerializer < BaseSerializer
    has_many :permissions, predicate: NS::ARGU[:permission]
  end
end
