# frozen_string_literal: true

class MotionSerializer < ContentEdgeSerializer
  has_many :custom_placements, predicate: NS::SCHEMA[:location]
  attribute :current_vote, predicate: NS::ARGU[:currentVote], unless: :system_scope?
  count_attribute :votes_pro, if: :export_scope?
  count_attribute :votes_con, if: :export_scope?
  count_attribute :votes_neutral, if: :export_scope?

  def current_vote
    object.current_vote&.for
  end

  def votes_con_count
    object.default_vote_event.con_count
  end

  def votes_neutral_count
    object.default_vote_event.neutral_count
  end

  def votes_pro_count
    object.default_vote_event.pro_count
  end
end
