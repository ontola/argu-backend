# frozen_string_literal: true

class VoteEventPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope
    def resolve
      scope
    end
  end

  def show?
    Pundit.policy(context, record.parent_model).show?
  end
end
