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
      validates :argu_publication, presence: true
      before_validation :build_default_publication
      attr_writer :is_draft

      def is_draft
        @is_draft ||= new_record? || published_publications.empty?
      end
      alias_method :is_draft?, :is_draft

      def is_publishable?
        true
      end

      def published_at
        argu_publication.try(:published_at)
      end

      private

      def build_default_publication
        argu_publication || build_argu_publication(
          channel: :argu,
          creator: creator,
          publisher: publisher,
          published_at: Time.current
        )
      end
    end

    module ClassMethods
      def build_new(opts)
        resource = super
        resource.build_argu_publication(
          follow_type: 'reactions'
        )
        resource
      end

      def is_publishable?
        true
      end
    end
  end

  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def is_publishable?
        false
      end
    end

    def is_publishable?
      false
    end
  end
  ActiveRecord::Base.include ActiveRecordExtension
end
