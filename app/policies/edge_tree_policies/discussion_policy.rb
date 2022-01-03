# frozen_string_literal: true

class DiscussionPolicy < EdgePolicy
  private

  def child_instance(parent, klass, user_context: nil)
    user_context.build_child(parent, klass)
  end

  def motion_policy
    @motion_policy ||=
      Pundit.policy(context, child_instance(record.parent, Motion, user_context: user_context))
  end

  def question_policy
    @question_policy ||=
      Pundit.policy(context, child_instance(record.parent, Question, user_context: user_context))
  end
end
