# frozen_string_literal: true

module ProfilePhotoable
  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :default_profile_photo, predicate: NS::SCHEMA[:image]
    end
  end
end
