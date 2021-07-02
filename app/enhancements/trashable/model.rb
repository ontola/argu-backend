# frozen_string_literal: true

module Trashable
  module Model
    extend ActiveSupport::Concern

    included do
      has_one :trash_activity,
              -> { where("key ~ '*.trash'").order(created_at: :desc) },
              class_name: 'Activity',
              foreign_key: :trackable_edge_id,
              primary_key: :uuid
      has_one :untrash_activity,
              -> { where("key ~ '*.untrash'").order(created_at: :desc) },
              class_name: 'Activity',
              foreign_key: :trackable_edge_id,
              primary_key: :uuid
      accepts_nested_attributes_for :trash_activity
      accepts_nested_attributes_for :untrash_activity

      scope :anonymous, -> { where(creator_id: Profile::COMMUNITY_ID) }
    end

    def is_trashable?
      true
    end

    def trash
      return if trashed_at.present?

      self.class.transaction do
        self.trashed_at = Time.current
        save(validate: false)
        run_callbacks :trash
      end
      true
    end

    def untrash
      return if trashed_at.nil?

      self.class.transaction do
        self.trashed_at = nil
        save(validate: false)
        run_callbacks :untrash
      end
      true
    end

    module ClassMethods
      def is_trashable?
        true
      end

      # Scope to conditionally filter trashed items
      # @param [boolean] show_trashed Whether trashed records should be included
      # @return [ActiveRecord::Relation]
      def show_trashed(show_trashed = nil)
        show_trashed ? where(nil) : untrashed
      end
    end
  end

  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def is_trashable?
        false
      end
    end

    # Useful to test whether a model uses {Trashable}
    def is_trashable?
      false
    end
  end
  ActiveRecord::Base.include ActiveRecordExtension
end
