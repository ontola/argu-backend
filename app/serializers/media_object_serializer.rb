# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  include Parentable::Serializer

  attribute :url, predicate: NS::SCHEMA[:url]
  attribute :thumbnail, predicate: NS::SCHEMA[:thumbnail]
  attribute :position_y, predicate: NS::ARGU[:imagePositionY]
  attribute :used_as

  def type
    object.is_image? ? NS::SCHEMA[:ImageObject] : NS::SCHEMA[:MediaObject]
  end
end
