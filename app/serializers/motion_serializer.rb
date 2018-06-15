# frozen_string_literal: true

class MotionSerializer < ContentEdgeSerializer
  attribute :current_vote, predicate: NS::ARGU[:currentVote], unless: :system_scope?
  attribute :pro_count, if: :export_scope?
  attribute :con_count, if: :export_scope?
  attribute :neutral_count, if: :export_scope?

  def current_vote
    object.current_vote&.for
  end

  def con_count
    object.default_vote_event.con_count
  end

  def neutral_count
    object.default_vote_event.neutral_count
  end

  def pro_count
    object.default_vote_event.pro_count
  end
end
