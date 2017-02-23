# frozen_string_literal: true
module Attachable
  extend ActiveSupport::Concern

  included do
    has_many :attachments,
             -> { where(used_as: MediaObject.used_as[:attachment]) },
             class_name: 'MediaObject',
             as: :about,
             inverse_of: :about
    accepts_nested_attributes_for :attachments,
                                  allow_destroy: true,
                                  reject_if: proc { |attrs|
                                    attrs['content'].blank? &&
                                      attrs['content_cache'].blank? &&
                                      attrs['remove_content'] != '1' &&
                                      attrs['remote_content_url'].blank? &&
                                      attrs['description'].blank?
                                  }

    with_collection :attachments, pagination: true, association_class: MediaObject, filter: {used_as: :attachment}
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :attachment_collection do
        link(:self) do
          {
            href: "#{object.context_id}/media_objects?filter[used_as]=attachment",
            meta: {
              '@type': 'argu:attachments'
            }
          }
        end
        meta do
          href = object.context_id
          {
            '@type': 'argu:collectionAssociation',
            '@id': "#{href}/media_objects?filter[used_as]=attachment"
          }
        end
      end

      def attachment_collection
        object.attachment_collection(user_context: scope)
      end
    end
  end
end
