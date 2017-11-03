# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  attribute :url, predicate: NS::SCHEMA[:url]
  attribute :thumbnail, predicate: NS::SCHEMA[:thumbnail]
  attribute :used_as

  def type
    object.is_image? ? NS::SCHEMA[:ImageObject] : NS::SCHEMA[:MediaObject]
  end
end
