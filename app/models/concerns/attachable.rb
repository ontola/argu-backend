# frozen_string_literal: true

module Attachable
  extend ActiveSupport::Concern

  included do
    has_many :media_objects, as: :about, inverse_of: :about, dependent: :destroy, primary_key: :uuid
    has_many :attachments,
             -> { where(used_as: MediaObject.used_as[:attachment]) },
             class_name: 'MediaObject',
             as: :about,
             inverse_of: :about,
             primary_key: :uuid
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
      with_collection :attachments, predicate: NS::ARGU[:attachments]
    end
  end
end
