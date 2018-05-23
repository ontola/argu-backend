# frozen_string_literal: true

class VoteEventPolicy < EdgePolicy
  class Scope < EdgePolicy::Scope
    def resolve
      scope
    end
  end

  def destroy?
    false
  end
end
