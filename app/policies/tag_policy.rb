# frozen_string_literal: true
class TagPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
