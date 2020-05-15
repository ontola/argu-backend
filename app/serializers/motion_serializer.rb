# frozen_string_literal: true

class MotionSerializer < DiscussionSerializer
  attribute :lat, if: method(:export_scope?) do |object|
    object.custom_placement&.lat
  end
  attribute :lon, if: method(:export_scope?) do |object|
    object.custom_placement&.lon
  end

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
