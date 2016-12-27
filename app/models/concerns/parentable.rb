# frozen_string_literal: true
# Concern that gives models the `Parentable` functionality in cooperation with {Context}
#
# A model using Parentable needs to call {Parentable::ClassMethods#parentable} to define which associations
# qualify to be parent.
module Parentable
  extend ActiveSupport::Concern

  included do
    include Edgeable
    validate :validate_parent_type

    def validate_parent_type
      return if edge.nil? || self.class.parent_classes.include?(edge.parent.owner_type.underscore.to_sym)
      errors.add(:parent, "#{edge.parent.owner_type} is not permitted as parent for #{class_name}")
    end

    # Simple method to verify that a model uses {Parentable}
    def is_fertile?
      true
    end

    def self.is_fertile?
      true
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
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
