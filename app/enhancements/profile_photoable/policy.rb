# frozen_string_literal: true

module ProfilePhotoable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(
        default_profile_photo_attributes: Pundit.policy(context, MediaObject.new(about: record)).permitted_attributes
      )
      attributes
    end
  end
end
