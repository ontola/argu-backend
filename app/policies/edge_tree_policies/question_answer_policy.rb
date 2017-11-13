# frozen_string_literal: true

class QuestionAnswerPolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i[id motion_id question_id]
    attributes
  end

  def create?
    edgeable_policy.update?
  end

  def shortname?
    false
  end

  private

  def edgeable_record
    @edgeable_record ||= record.question
  end
end
