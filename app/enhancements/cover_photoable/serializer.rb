# frozen_string_literal: true

module CoverPhotoable
  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :default_cover_photo, predicate: NS::ARGU[:coverPhoto]
    end
  end
end
