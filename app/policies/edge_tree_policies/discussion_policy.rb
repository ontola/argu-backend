# frozen_string_literal: true

class DiscussionPolicy < EdgePolicy
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
