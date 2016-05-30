module ProfilePhotoable
  extend ActiveSupport::Concern

  included do
    has_one :default_profile_photo,
            -> { where(used_as: Photo.used_as[:profile_photo]) },
            as: :about,
            class_name: 'Photo',
            inverse_of: :about,
            required: true,
            autosave: true

    accepts_nested_attributes_for :default_profile_photo,
                                  allow_destroy: true,
                                  reject_if: proc { |attrs|
                                    attrs['image'].blank? &&
                                      attrs['image_cache'].blank? &&
                                      attrs['remove_image'] != '1' &&
                                      attrs['remote_profile_photo_url'].blank?
                                  }

    before_validation :build_profile_photo
    before_save :remove_marked_profile_photo
  end

  def build_profile_photo
    build_default_profile_photo(photo_params) unless default_profile_photo.present?
  end

  def photo_params
    case self
    when Profile
      if profileable.is_a?(Page)
        {publisher: profileable.owner.profileable, creator: self, forum: nil}
      else
        {publisher: profileable, creator: self, forum: nil}
      end
    when Forum
      {publisher: page.owner.profileable, creator: creator, forum: self}
    end
  end

  def remove_marked_profile_photo
    default_profile_photo.save if default_profile_photo.remove_image
  end
end
