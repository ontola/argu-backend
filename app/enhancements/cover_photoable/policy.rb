# frozen_string_literal: true

module CoverPhotoable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_nested_attributes %i[default_cover_photo]
    end
  end
end
