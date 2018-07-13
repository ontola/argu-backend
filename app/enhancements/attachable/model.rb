# frozen_string_literal: true

module Attachable
  module Model
    extend ActiveSupport::Concern

    included do
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

      with_collection :attachments, association_class: MediaObject, filter: {used_as: :attachment}
    end
  end
end
