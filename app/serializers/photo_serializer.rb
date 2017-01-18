# frozen_string_literal: true
class PhotoSerializer < BaseSerializer
  attributes :id, :url, :thumbnail

  def thumbnail
    url = object.url(:icon)
    url.include?('gravatar.com') ? url : "#{object.url(:icon)}"
  end
end
