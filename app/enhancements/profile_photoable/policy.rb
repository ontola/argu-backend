# frozen_string_literal: true

module ProfilePhotoable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_nested_attributes %i[default_profile_photo], new_record: false
    end
  end
end
