# frozen_string_literal: true

# Concern for Models that use Activities to keep a log of changes
module Loggable
  extend ActiveSupport::Concern

  included do
    has_many :activities,
             -> { where("key ~ '*.!happened'") },
             foreign_key: :trackable_edge_id,
             primary_key: :uuid,
             dependent: :nullify
    has_one :trash_activity,
            -> { where("key ~ '*.trash'").order(created_at: :desc) },
            class_name: 'Activity',
            foreign_key: :trackable_edge_id,
            primary_key: :uuid
    before_destroy :destroy_notifications, prepend: true

    def destroy_notifications
      activities.each do |activity|
        activity.notifications.destroy_all
      end
    end

    def is_loggable?
      true
    end

    def self.is_loggable?
      true
    end

    # Returns the first found trashed_activity of self and ancestors
    # @return [Activity, nil]
    def first_trashed_activity
      trashed_ancestors.first&.trash_activity
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.class_eval do
        def self.is_loggable?
          false
        end
      end
    end

    def is_loggable?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
