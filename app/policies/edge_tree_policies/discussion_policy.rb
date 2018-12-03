# frozen_string_literal: true

class DiscussionPolicy < EdgePolicy
  def show?
    parent_policy.list?
    parent_policy.show?
  end

  def create?
    parent_policy.list?
    motion_policy.create? || question_policy.create?
  end

  private

  def motion_policy
    @motion_policy ||=
      Pundit.policy(context, child_instance(record.parent, Motion))
  end

  def question_policy
    @question_policy ||=
      Pundit.policy(context, child_instance(record.parent, Question))
  end
end
