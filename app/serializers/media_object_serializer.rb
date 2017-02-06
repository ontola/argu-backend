# frozen_string_literal: true
class MediaObjectSerializer < RecordSerializer
  def self.type(type = nil, &block)
    self._type = block || type
  end
  type(&:ld_type)
  attributes :url, :thumbnail, :used_as

  def thumbnail
    url = object.url(:icon)
    url.include?('gravatar.com') ? url : "https://argu-logos.s3.amazonaws.com#{object.url(:icon)}"
  end
end
