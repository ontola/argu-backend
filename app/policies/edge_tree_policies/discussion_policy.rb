# frozen_string_literal: true

class DiscussionPolicy < EdgeTreePolicy
  def show?
    edgeable_policy.list?
    edgeable_policy.show?
  end

  def create?
    motion_policy.create? || question_policy.create?
  end

  private

  def motion_policy
    @motion_policy ||=
      Pundit.policy(context, child_instance(edgeable_record, Motion))
  end

  def question_policy
    @question_policy ||=
      Pundit.policy(context, child_instance(edgeable_record, Question))
  end
end
