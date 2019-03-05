# frozen_string_literal: true

module CoverPhotoable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      photo_attrs = Pundit.policy(context, MediaObject.new(about: record)).permitted_attributes
      attributes.append(
        default_cover_photo_attributes: photo_attrs
      )
      attributes
    end
  end
end
