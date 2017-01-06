# frozen_string_literal: true
module Trashable
  extend ActiveSupport::Concern

  included do
    scope :anonymous, -> { where(creator_id: Profile::COMMUNITY_ID) }
  end

  delegate :trash, :untrash, :is_trashed?, to: :edge

  def is_trashable?
    true
  end

  module ClassMethods
    def is_trashable?
      true
    end

    # Scope to conditionally filter trashed items
    # @param [boolean] trashed Whether trashed records should be included
    # @return [ActiveRecord::Relation]
    def show_trashed(show_trashed = nil)
      show_trashed ? where(nil) : untrashed
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.class_eval do
        def self.is_trashable?
          false
        end
      end
    end

    # Useful to test whether a model uses {Trashable}
    def is_trashable?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
