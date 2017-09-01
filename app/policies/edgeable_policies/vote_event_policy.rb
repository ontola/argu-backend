# frozen_string_literal: true

class VoteEventPolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope
    def resolve
      scope
    end
  end

  def create?
    false
  end

  def trash?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def show?
    Pundit.policy(context, record.parent_model).show?
  end
end
