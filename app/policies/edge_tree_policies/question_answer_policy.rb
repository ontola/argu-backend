# frozen_string_literal: true

class QuestionAnswerPolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[motion_id question_id]

  def create?
    edgeable_policy.update?
  end

  private

  def edgeable_record
    @edgeable_record ||= record.question
  end
end
