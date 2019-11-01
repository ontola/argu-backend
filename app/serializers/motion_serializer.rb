# frozen_string_literal: true

class MotionSerializer < DiscussionSerializer
  attribute :lat, if: :export_scope?
  attribute :lon, if: :export_scope?

  count_attribute :votes_pro, if: :export_scope?
  count_attribute :votes_con, if: :export_scope?
  count_attribute :votes_neutral, if: :export_scope?

  def lat
    object.custom_placement&.lat
  end

  def lon
    object.custom_placement&.lon
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
