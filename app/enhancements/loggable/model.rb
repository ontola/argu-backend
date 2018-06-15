# frozen_string_literal: true

# Concern for Models that use Activities to keep a log of changes
module Loggable
  module Model
    extend ActiveSupport::Concern

    included do
      before_destroy :destroy_notifications, prepend: true
    end

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
