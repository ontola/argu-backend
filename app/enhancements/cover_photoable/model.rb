# frozen_string_literal: true

module CoverPhotoable
  module Model
    extend ActiveSupport::Concern

    included do
      has_one :default_cover_photo,
              -> { where(used_as: MediaObject.used_as[:cover_photo]) },
              as: :about,
              dependent: :destroy,
              inverse_of: :about,
              class_name: 'ImageObject',
              primary_key: :uuid

      accepts_nested_attributes_for :default_cover_photo,
                                    allow_destroy: true,
                                    reject_if: proc { |attrs|
                                      attrs['content'].blank? &&
                                        attrs['content_cache'].blank? &&
                                        attrs['remove_content'] != '1' &&
                                        attrs['remote_content_url'].blank?
                                    }
    end

    module ClassMethods
      def includes_for_serializer
        super.merge(default_cover_photo: {})
      end

      def preview_includes
        super + %i[default_cover_photo]
      end
    end
  end
end
