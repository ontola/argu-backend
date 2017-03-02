# frozen_string_literal: true
class MediaObjectSerializer < RecordSerializer
  delegate :context_type, to: :object
  def self.type(type = nil, &block)
    self._type = block || type
  end
  type(&:context_type)
  attributes :url, :thumbnail, :used_as

  def thumbnail
    url = object.url(:icon)
    return url if Rails.env.production? || url&.include?('gravatar.com')
    "https://argu-logos.s3.amazonaws.com#{object.url(:icon)}"
  end
end
