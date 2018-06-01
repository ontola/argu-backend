# frozen_string_literal: true

# Concern that gives models the `Parentable` functionality in cooperation with {Context}
#
# A model using Parentable needs to call {Parentable::ClassMethods#parentable} to define which associations
# qualify to be parent.
module Parentable
  extend ActiveSupport::Concern

  included do
    # Simple method to verify that a model uses {Parentable}
    def is_fertile?
      true
    end

    def self.is_fertile?
      true
    end

    def parent
      self.class.parent_classes.detect { |t| break send(t) if send(t) }
    end

    delegate :ancestor, to: :parent

    def parent_iri(opts = {})
      parent&.iri(opts)
    end
  end

  module ClassMethods
    # Add to a model which includes {Parentable} to set the possible parents for the model
    # @param relation [Symbol splat] List of symbolized model names.
    def parentable(*relation)
      cattr_accessor :parent_classes do
        relation
      end
    end
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :parent, key: :parent, predicate: NS::SCHEMA[:isPartOf]
      # rubocop:enable Rails/HasManyOrHasOneDependent
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.class_eval do
        def self.is_fertile?
          false
        end
      end
    end

    # Useful to test whether a model is (not) fertile
    def is_fertile?
      false
    end

    def store_in_redis?(_opts = {})
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
