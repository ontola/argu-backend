# frozen_string_literal: true
module Photoable
  extend ActiveSupport::Concern

  included do
    has_many :photos, as: :about, dependent: :destroy
    has_one :default_cover_photo,
            -> { where(used_as: Photo.used_as[:cover_photo]) },
            as: :about,
            inverse_of: :about,
            class_name: 'Photo'

    accepts_nested_attributes_for :default_cover_photo,
                                  allow_destroy: true,
                                  reject_if: proc { |attrs|
                                    attrs['image'].blank? &&
                                      attrs['image_cache'].blank? &&
                                      attrs['remove_image'] != '1' &&
                                      attrs['remote_profile_photo_url'].blank?
                                  }
  end
end
