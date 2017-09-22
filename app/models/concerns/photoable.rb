# frozen_string_literal: true

module Photoable
  extend ActiveSupport::Concern

  included do
    has_many :media_objects, as: :about, inverse_of: :about, dependent: :destroy
    has_one :default_cover_photo,
            -> { where(used_as: MediaObject.used_as[:cover_photo]) },
            as: :about,
            dependent: :destroy,
            inverse_of: :about,
            class_name: 'MediaObject'

    accepts_nested_attributes_for :default_cover_photo,
                                  allow_destroy: true,
                                  reject_if: proc { |attrs|
                                    attrs['content'].blank? &&
                                      attrs['content_cache'].blank? &&
                                      attrs['remove_content'] != '1' &&
                                      attrs['remote_content_url'].blank?
                                  }
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :default_cover_photo do
        obj = object.default_cover_photo
        if obj
          link(:self) do
            {
              meta: {
                '@type': 'argu:coverPhoto'
              }
            }
          end
          link(:related) do
            {
              href: obj.context_id,
              meta: {
                '@type': 'schema:imageObject'
              }
            }
          end
        else
          link(:self) do
            {
              meta: {
                '@type': 'argu:coverPhoto'
              }
            }
          end
          link(:related) do
            {
              href: nil,
              meta: {
                '@type': 'schema:imageObject'
              }
            }
          end
        end
        obj
      end
    end
  end
end
