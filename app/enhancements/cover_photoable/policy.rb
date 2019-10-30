# frozen_string_literal: true

module CoverPhotoable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      return super if record.try(:owner)&.is_a?(Page)

      attributes = super
      photo_attrs = Pundit.policy(context, MediaObject.new(about: record)).permitted_attributes
      attributes.append(
        default_cover_photo_attributes: photo_attrs
      )
      attributes
    end
  end
end
