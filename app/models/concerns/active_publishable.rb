# frozen_string_literal: true
module ActivePublishable
  extend ActiveSupport::Concern

  included do
    has_many :publications,
             through: :edge

    has_one :argu_publication,
            -> { where(channel: 'argu') },
            class_name: 'Publication',
            through: :edge
  end

  def is_draft?
    publications.where('published_at IS NOT NULL').empty?
  end

  def is_publishable?
    true
  end

  def published_at
    argu_publication.try(:published_at)
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
