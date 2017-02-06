# frozen_string_literal: true
class MediaObjectSerializer < BaseSerializer
  attributes :id, :url, :thumbnail

  def thumbnail
    url = object.url(:icon)
    url.include?('gravatar.com') ? url : "https://argu-logos.s3.amazonaws.com#{object.url(:icon)}"
  end
end
