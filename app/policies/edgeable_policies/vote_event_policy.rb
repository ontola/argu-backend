# frozen_string_literal: true

class VoteEventPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope
    def resolve
      scope
    end
  end

  def destroy?
    false
  end
end
