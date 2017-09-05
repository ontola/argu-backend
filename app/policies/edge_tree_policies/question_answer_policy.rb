# frozen_string_literal: true

class QuestionAnswerPolicy < EdgeTreePolicy
  class Scope < RestrictivePolicy::Scope
    def resolve
      scope
    end
  end

  def edge
    record.question.edge
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i[id motion_id question_id]
    attributes
  end

  def create?
    rule is_manager?, is_super_admin?, super
  end

  def shortname?
    false
  end
end
