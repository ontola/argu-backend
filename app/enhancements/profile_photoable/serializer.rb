# frozen_string_literal: true

module ProfilePhotoable
  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :default_profile_photo, predicate: NS.argu[:profilePhoto] do |object|
        object.default_profile_photo unless object.default_profile_photo&.gravatar_url?
      end
      has_one :profile_photo_with_fallback, predicate: NS.schema.image, &:default_profile_photo
    end
  end
end
