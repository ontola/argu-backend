# frozen_string_literal: true

class MediaObjectSerializer < RecordSerializer
  delegate :context_type, to: :object
  def self.type(type = nil, &block)
    self._type = block || type
  end
  type(&:context_type)
  attributes :url, :thumbnail, :used_as, :position_y

  def position_y
    object.content_attributes.try(:[], 'position_y')
  end

  def url
    url = object.cover_photo? ? object.url(:cover) : object.url
    return {'@id': "https:/#{url}"} if Rails.env.production? || url&.include?('gravatar.com')
    {'@id': "https://argu-logos.s3.amazonaws.com#{url}"}
  end

  def thumbnail
    url = object.url(:icon)
    return {'@id': "https:/#{url}"} if Rails.env.production? || url&.include?('gravatar.com')
    {'@id': "https://argu-logos.s3.amazonaws.com#{object.url(:icon)}"}
  end
end
