# frozen_string_literal: true

module ProfilePhotoable
  module Model
    extend ActiveSupport::Concern

    included do
      enhance Mediable

      has_one :default_profile_photo,
              -> { where(used_as: MediaObject.used_as[:profile_photo]) },
              as: :about,
              class_name: 'ImageObject',
              dependent: :destroy,
              inverse_of: :about,
              autosave: true,
              primary_key: :uuid

      accepts_nested_attributes_for :default_profile_photo,
                                    allow_destroy: true,
                                    update_only: true,
                                    reject_if: proc { |attrs|
                                      attrs['content'].blank? &&
                                        attrs['remote_content_url'].blank?
                                    }

      before_validation :build_profile_photo, if: :require_profile_photo?
    end

    def build_profile_photo
      return if default_profile_photo.present? && !default_profile_photo.marked_for_destruction?

      build_default_profile_photo(photo_params)
    end

    def photo_params
      case self
      when Profile
        if profileable.is_a?(Page)
          {publisher: profileable.publisher, creator: self, forum: nil}
        else
          {publisher: profileable, creator: self, forum: nil}
        end
      when Forum
        {publisher: publisher, creator: creator, forum: self}
      end
    end

    private

    def require_profile_photo?
      self.class.require_profile_photo?
    end

    module ClassMethods
      def preview_includes
        super + [:default_profile_photo]
      end

      def require_profile_photo?
        true
      end
    end
  end
end
