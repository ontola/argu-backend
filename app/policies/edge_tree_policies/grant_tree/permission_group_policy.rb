# frozen_string_literal: true

class GrantTree
  class PermissionGroupPolicy < EdgeTreePolicy
    class Scope < EdgeTreePolicy::Scope
      def resolve
        scope
      end
    end

    def show?
      administrator? || staff?
    end
  end
end
