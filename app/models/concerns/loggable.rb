# frozen_string_literal: true
# Concern for Models that use Activities to keep a log of changes
module Loggable
  extend ActiveSupport::Concern

  included do
    has_many :activities,
             -> { where("key ~ '*.!happened'") },
             as: :trackable

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
  end

  module Serlializer
    extend ActiveSupport::Concern
    included do
      link(:log) { log_url(object.edge) }
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
