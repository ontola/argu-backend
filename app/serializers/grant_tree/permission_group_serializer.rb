# frozen_string_literal: true

class GrantTree
  class PermissionGroupSerializer < BaseSerializer
    with_collection :permissions, predicate: NS.argu[:permission]
    has_one :group, predicate: NS.argu[:group]
    has_many :grant_sets, predicate: NS.argu[:grantSets]

    GrantReset.action_names.each_key do |action|
      attribute action, predicate: NS.argu["#{action}Permission"]
    end
    GrantReset.resource_types.except.keys.map do |type|
      attribute "create_#{type.underscore}", predicate: NS.argu["create#{type}Permission"]
    end
  end
end
