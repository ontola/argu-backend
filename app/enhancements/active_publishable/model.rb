# frozen_string_literal: true

module ActivePublishable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :publications,
               foreign_key: :publishable_id,
               dependent: :destroy,
               primary_key: :uuid
      has_many :published_publications,
               -> { where('publications.published_at IS NOT NULL') },
               class_name: 'Publication',
               foreign_key: :publishable_id,
               primary_key: :uuid
      has_one :argu_publication,
              -> { where(channel: 'argu') },
              class_name: 'Publication',
              foreign_key: :publishable_id,
              primary_key: :uuid
      accepts_nested_attributes_for :argu_publication

      def is_draft?
        published_publications.empty?
      end

      def is_publishable?
        true
      end

      def published_at
        argu_publication.try(:published_at)
      end
    end

    module ClassMethods
      def includes_for_serializer
        super.merge(argu_publication: {}, published_publications: {})
      end

      def is_publishable?
        true
      end
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.class_eval do
        def self.is_publishable?
          false
        end
      end
    end

    def is_publishable?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
