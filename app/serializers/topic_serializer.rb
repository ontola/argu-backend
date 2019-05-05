# frozen_string_literal: true

class TopicSerializer < DiscussionSerializer
  attribute :lat, if: :export_scope?
  attribute :lon, if: :export_scope?

  def lat
    object.custom_placement&.lat
  end

  def lon
    object.custom_placement&.lon
  end
end
