# frozen_string_literal: true

class GrantTree
  class PermissionSerializer < BaseSerializer
    has_one :target_class, predicate: NS.sh.targetClass
    has_one :permission_group, predicate: NS.schema.isPartOf

    GrantReset.action_names.each_key do |action|
      attribute action, predicate: NS.argu["#{action}Permission"]
    end
  end
end
