# frozen_string_literal: true
class VoteEventPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      scope
    end
  end

  def show?
    Pundit.policy(context, record.parent_model).show?
  end
end
