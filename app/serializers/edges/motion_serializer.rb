# frozen_string_literal: true

class MotionSerializer < DiscussionSerializer
  count_attribute :votes_pro, if: method(:export_scope?) do |object|
    object.default_vote_event.pro_count
  end
  count_attribute :votes_con, if: method(:export_scope?) do |object|
    object.default_vote_event.con_count
  end
  count_attribute :votes_neutral, if: method(:export_scope?) do |object|
    object.default_vote_event.neutral_count
  end
end
