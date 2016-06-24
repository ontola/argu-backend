# Concern that gives models the `Parentable` functionality in cooperation with {Context}
#
# A model using Parentable needs to call {Parentable::ClassMethods#parentable} to define which associations
# qualify to be parent.
module Parentable
  extend ActiveSupport::Concern

  included do
    include Edgeable

    # Simple method to verify that a model uses {Parentable}
    def is_fertile?
      true
    end
  end

  # Check if this model is a child of `record`
  def is_child_of?(record)
    parent = parent_model
    if parent
      if parent.model == record
        true
      elsif parent.has_parent?
        parent.model.is_child_of?(record) if parent.model.try(:is_fertile?)
      else
        # This is false since it can't be parent of itself
        false
      end
    else
      false
    end
  end

  def parent_edge
    edge.parent
  end

  def parent_model
    parent_edge.owner
  end

  module ClassMethods
    # Add to a model which includes {Parentable} to set the possible parents for the model
    # @param relation [Symbol splat] List of symbolized model names.
    def parentable(*relation)
      cattr_accessor :parent_is do
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
