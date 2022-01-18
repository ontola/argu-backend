# frozen_string_literal: true

class GrantTree
  class NodePolicy < EdgeTreePolicy
    class Scope < EdgeTreePolicy::Scope
      def resolve
        return scope.none unless staff?

        scope
      end
    end

    def show?
      staff?
    end
  end
end
