# frozen_string_literal: true

module Attachable
  module Model
    extend ActiveSupport::Concern

    included do
      enhance Mediable

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

      with_collection :attachments,
                      association: :attachments,
                      association_class: MediaObject,
                      default_sortings: [{key: NS.schema.uploadDate, direction: :asc}],
                      parent_uri_template: :attachments_collection_iri
    end
  end
end
