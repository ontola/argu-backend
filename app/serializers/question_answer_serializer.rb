# frozen_string_literal: true

class QuestionAnswerSerializer < BaseSerializer
  attribute :motion, predicate: NS::SCHEMA[:motion]

  def id
    0
  end

  def motion
    object.motion.iri
  end
end
