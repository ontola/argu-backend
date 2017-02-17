# frozen_string_literal: true
class ListItemPolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end
end
