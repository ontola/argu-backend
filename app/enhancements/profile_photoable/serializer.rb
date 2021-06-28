# frozen_string_literal: true

module ProfilePhotoable
  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :default_profile_photo,
              predicate: NS.schema.image,
              serializer: :media_object
    end
  end
end
