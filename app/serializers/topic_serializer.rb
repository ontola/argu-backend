# frozen_string_literal: true

class TopicSerializer < DiscussionSerializer
  attribute :lat, if: method(:export_scope?) do |object|
    object.custom_placement&.lat
  end
  attribute :lon, if: method(:export_scope?) do |object|
    object.custom_placement&.lon
  end
end
