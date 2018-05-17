# frozen_string_literal: true

module ActivePublishable
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

    def is_draft?
      edge.published_publications.empty?
    end

    def is_publishable?
      true
    end

    def mark_as_important
      edge.argu_publication&.follow_type&.to_s == 'news'
    end

    def published_at
      argu_publication.try(:published_at)
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :argu_publication,
              predicate: NS::ARGU[:arguPublication]
      # rubocop:enable Rails/HasManyOrHasOneDependent
    end
  end

  module ClassMethods
    def is_publishable?
      true
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
